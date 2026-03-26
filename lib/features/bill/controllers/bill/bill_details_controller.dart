import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_items_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_model_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/interfaces/i_store_selection_handler.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/bill/data/models/delivery_item_model.dart';
import 'package:ba3_bs/features/bill/services/bill/bill_local_storage_service.dart';
import 'package:ba3_bs/features/bill/services/bill/bill_utils.dart';
import 'package:ba3_bs/features/customer/controllers/customers_controller.dart';
import 'package:ba3_bs/features/floating_window/managers/overlay_entry_with_priority_manager.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/custom_alert_dialog/helper_alert.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/floating_launcher.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/services/copy_paste_services/copy_paste_xml_service.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/whatsapp/whatsapp_service.dart';
import '../../../../core/use_cases/copy_paste_use_case.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../customer/data/models/customer_model.dart';
import '../../../materials/controllers/material_controller.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../materials/service/serial_number_model_factory.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../print/controller/print_controller.dart';
import '../../../print/dialogs/receipt_print_brand_dialog.dart';
import '../../../sellers/data/models/seller_model.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../../users_management/data/models/role_model.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/invoice_record_model.dart';
import '../../data/models/product_with_tax_model.dart';
import '../../services/bill/account_handler.dart';
import '../../services/bill/bill_details_service.dart';
import '../../../../core/dialogs/choose_columns_dialog.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillDetailsController extends IBillController
    with
        AppValidator,
        AppNavigator,
        FirestoreSequentialNumbers,
        FloatingLauncher
    implements IStoreSelectionHandler {
  // Repositories

  final CompoundDatasourceRepository<BillModel, BillTypeModel>
      _billsFirebaseRepo;

  final QueryableSavableRepository<SerialNumberModel> _serialNumbersRepo;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;
  final List<ProductWithTaxModel> productsWithTax = [];
  bool viewBillItemWithTax = false;

  BillDetailsController(
    this._billsFirebaseRepo,
    this._serialNumbersRepo, {
    required this.billDetailsPlutoController,
    required this.billSearchController,
  });

  // Services
  late final BillDetailsService _billService;
  late final BillUtils _billUtils;
  late final AccountHandler _accountHandler;

  final formKey = GlobalKey<FormState>();
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController =
      TextEditingController();
  final TextEditingController billAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  final TextEditingController orderNumberController = TextEditingController();

  final TextEditingController customerPhoneController = TextEditingController();
  final TextEditingController firstPayController = TextEditingController();
  final TextEditingController invReturnDateController = TextEditingController();
  final TextEditingController invReturnCodeController = TextEditingController();
  final TextEditingController invFirstPayController = TextEditingController();

  CustomerModel? selectedCustomerAccount;
  AccountModel? selectedBillAccount;
  SellerModel? selectedSellerAccount;

  Rx<bool> get isAccountReadOnly =>
      (selectedPayType.value == InvPayType.cash).obs;

  Rx<DateTime> billDate = DateTime.now().obs;

  Rx<InvPayType> selectedPayType = InvPayType.cash.obs;

  BillType billType = BillType.sales;
  bool isLoading = true;

  RxBool isBillSaved = false.obs;

  @override
  Rx<StoreAccount> selectedStore = StoreAccount.main.obs;

  bool get isCash => selectedPayType.value == InvPayType.cash;

  Rx<RequestState> saveBillRequestState = RequestState.initial.obs;

  Rx<RequestState> deleteBillRequestState = RequestState.initial.obs;

  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) {
      selectedStore.value = newStore;
    }
  }

  // @override
  void updateCustomerAccount(
      CustomerModel? newAccount, BillTypeModel billTypeModel) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
      customerAccountController.text = newAccount.name!;
      if (billTypeModel.isPurchaseRelated &&
          newAccount.customerHasVat != true) {
        billDetailsPlutoController.clearVat();
      } else {
        billDetailsPlutoController.returnVat();
      }
    }
  }

  void updateBillAccount(AccountModel? newAccount) {
    if (newAccount != null) {
      selectedBillAccount = newAccount;
      billAccountController.text = newAccount.accName!;
    } else {
      selectedBillAccount = null;
      billAccountController.text = '';
    }
  }

  @override
  Future<void> sendToEmail(
      {required String recipientEmail,
      String? url,
      String? subject,
      String? body,
      List<String>? attachments,
      required BuildContext context}) async {
    _billService.sendToEmail(
      recipientEmail: recipientEmail,
      url: url,
      subject: subject,
      body: body,
      attachments: attachments,
    );
  }

  @override
  set updateIsBillSaved(bool newValue) {
    isBillSaved.value = newValue;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _billService = BillDetailsService(
      plutoController: billDetailsPlutoController,
      billDetailsController: this,
    );
    _billUtils = BillUtils();
    _accountHandler = AccountHandler();
  }

  Future<bool> validateForm(BuildContext context) async {
    bool validate = true;
    if (selectedSellerAccount == null) {
      return await HelperAlert.showConfirm(
        context: context,
        text: AppStrings.areYouSureContinueWithoutSeller.tr,
      );
    }
    return validate;
  }

  bool get requiredRequestNumber =>
      selectedBillAccount?.requiredRequestNumber ?? false;

  String? validator(String? value, String fieldName) =>
      isFieldValid(value, fieldName);

  void updateBillType(String billTypeLabel) =>
      billType = BillType.byLabel(billTypeLabel);

  set setBillDate(DateTime newDate) {
    billDate.value = newDate;
    //   update();
  }

  void onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType.value = payType;
      if (payType == InvPayType.cash) {
        final primaryCashAccount = read<AccountsController>()
            .getAccountModelById(AppConstants.primaryCashAccountId);
        updateBillAccount(primaryCashAccount);
      }
      log('onPayTypeChanged');
    }
  }

  Future<void> printBill(
      {required BuildContext context,
      required BillModel billModel,
      required List<InvoiceRecordModel> invRecords}) async {
    if (!_billService.hasModelId(billModel.billId)) return;

    if (!context.mounted) return;
    final brand = await ReceiptPrintBrandDialog.show();
    if (brand == null || !context.mounted) return;

    await read<PrintingController>().printReceipt80(
      date: billDate.value.dayMonthYear,
      items: invRecords,
      seller: selectedSellerAccount?.costName ?? '',
      billNumber: billModel.billDetails.billNumber!,
      customer: billModel.billDetails.customerPhone!,
      nots: billModel.billDetails.billNote ?? '',
      buyer: read<AccountsController>().getAccountNameById(
          billModel.billTypeModel.accounts?[BillAccounts.caches]?.id),
      receiptPrintBrand: brand,
    );
  }

  void launchFloatingEntryBondDetailsScreen(
      BillModel billModel, BuildContext context) async {
    if (!await validateForm(context)) return;
    if (!context.mounted) return;
    _billService.launchFloatingEntryBondDetailsScreen(
      context: context,
      billModel: billModel,
    );
  }

  void updateBillStatus(
      BillModel billModel, newStatus, BuildContext context) async {
    if (AppConstants.forcePending) {
      final success = await AppUIUtils.askForPassword(context);
      if (!success) return;
    }
    if (billModel.items.itemList
        .map((e) => e.itemName)
        .contains('الباركود خطأ')) {
      AppUIUtils.onFailure(
        'لا يمكن تغيير حالة الفاتورة بسبب وجود باركود خطأ',
      );
      return;
    } else {
      final result =
          await _billsFirebaseRepo.save(billModel.copyWith(status: newStatus));

      result.fold(
        (failure) => AppUIUtils.onFailure(
          failure.message,
        ),
        (updatedBillModel) => _billService.handleUpdateBillStatusSuccess(
          updatedBillModel: updatedBillModel,
          billSearchController: billSearchController,
          context: context,
        ),
      );
    }
  }

  Future<void> markAsAudited(
    BillModel bill,
    BuildContext context,
    bool targetAuditedState, // true = تدقيق، false = إلغاء التدقيق
  ) async {
    // إذا كانت الحالة الحالية نفس الحالة المطلوبة → لا نفعل شيء
    if (bill.isAudited == targetAuditedState) {
      return;
    }

    final String confirmMessage = targetAuditedState
        ? "هل أنت متأكد من أنك تريد تدقيق هذه الفاتورة؟"
        : "هل أنت متأكد من أنك تريد إلغاء تدقيق هذه الفاتورة؟";

    final bool? confirmed = await showAuditConfirmationOverlay(
      context,
      targetAuditedState,
      confirmMessage,
    );

    // إذا لم يؤكد المستخدم → نخرج
    if (confirmed != true) {
      return;
    }

    final currentUser = read<UserManagementController>().loggedInUserModel;
    if (currentUser == null) {
      AppUIUtils.onFailure("لا يمكن تحديد هوية المستخدم الحالي");
      return;
    }

    final updatedBill = bill.copyWith(
      isAudited: targetAuditedState,
      auditedBy: targetAuditedState ? (currentUser.userName) : null,
      auditedAt: targetAuditedState ? DateTime.now() : null,
    );

    final result = await _billsFirebaseRepo.save(updatedBill);

    result.fold(
      (failure) {
        AppUIUtils.onFailure("فشل في حفظ حالة التدقيق: ${failure.message}");
      },
      (savedBill) async {
        final successMsg = targetAuditedState
            ? "تم تدقيق الفاتورة بنجاح بواسطة ${savedBill.auditedBy}"
            : "تم إلغاء تدقيق الفاتورة بنجاح";
        // تحديث قائمة الفواتير
        billSearchController.updateBill(savedBill, successMsg);
        // رسالة نجاح مختلفة حسب الاتجاه

        AppUIUtils.onSuccess(successMsg);

        // تحديث تفاصيل الفاتورة على الشاشة
        updateBillDetailsOnScreen(savedBill, billDetailsPlutoController);
      },
    );
  }

  Future<bool?> showAuditConfirmationOverlay(
    BuildContext context,
    bool targetAuditedState,
    String confirmMessage,
  ) {
    final completer = Completer<bool?>();

    final overlay = Overlay.of(context);

    OverlayEntryWithPriorityManager.instance.displayOverlay(
      overlay: overlay,
      title: targetAuditedState ? "تأكيد التدقيق" : "تأكيد إلغاء التدقيق",
      width: 420,
      height: 230,
      priority: 0,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            confirmMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  OverlayEntryWithPriorityManager.instance.dispose();
                  completer.complete(false);
                },
                child: const Text(
                  "إلغاء",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  OverlayEntryWithPriorityManager.instance.dispose();
                  completer.complete(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: targetAuditedState
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                ),
                child: Text(
                  targetAuditedState
                      ? "نعم، دقق الفاتورة"
                      : "نعم، ألغِ التدقيق",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return completer.future;
  }

  Future<void> deleteBill(BillModel billModel, BuildContext context) async {
    if (!RoleItemType.viewBill.hasDeletePermission) {
      AppUIUtils.onFailure('You do not have permission to delete this bill.');
      return;
    }

    if (billModel.isPurchaseRelated) {
      if (await _hasSoldSerialNumbers(billModel, context)) return;
    }

    deleteBillRequestState.value = RequestState.loading;

    final result = await _billsFirebaseRepo.delete(billModel);

    await result.fold(
      (failure) {
        deleteBillRequestState.value = RequestState.error;
        AppUIUtils.onFailure(
          failure.message,
        );
      },
      (success) async {
        await _billService.handleDeleteSuccess(
          billToDelete: billModel,
          billSearchController: billSearchController,
          context: context,
        );
        deleteBillRequestState.value = RequestState.success;
      },
    );
  }

  /// Checks if deleting the bill would affect sold serial numbers.
  /// Returns `true` if deletion should be stopped.
  Future<bool> _hasSoldSerialNumbers(
      BillModel billModel, BuildContext context) async {
    final materialController = read<MaterialController>();

    for (BillItem item in billModel.items.itemList) {
      final mat = materialController.getMaterialById(
        item.itemGuid,
      );
      final serialNumbers = item.itemSerialNumbers ?? [];

      if (mat.serialNumbers != null) {
        for (final entry in mat.serialNumbers!.entries) {
          if (serialNumbers.contains(entry.key) && entry.value) {
            int? sellBillNumber = await _getSellBillNumber(entry.key);
            if (!context.mounted) return false;
            AppUIUtils.onFailure(
              '⚠️ لا يمكن حذف هذه الفاتورة! \n\n'
              '🔹 المادة: ${mat.matName} (${mat.id}, context)\n'
              '🔹 الرقم التسلسلي: [${entry.key}]\n'
              '🔹 تم بيعه بالفعل في فاتورة مبيعات ${sellBillNumber ?? ''}.\n\n'
              '❌ يرجى مراجعة الفواتير المرتبطة قبل المتابعة.',
            );
            return true; // Stop deletion
          }
        }
      }
    }
    return false; // Safe to delete
  }

  /// Fetches the sell bill number for a given serial number.
  Future<int?> _getSellBillNumber(String serialNumber) async {
    final result = await _serialNumbersRepo.getById(serialNumber);

    return result.fold(
      (failure) => null, // Return null on failure
      (SerialNumberModel serialsModel) => serialsModel.transactions.isNotEmpty
          ? serialsModel.transactions
              .where((transaction) => transaction.sold ?? false)
              .last
              .sellBillNumber
          : null,
    );
  }

  /// Deletes all sales transactions associated with a specific bill.
  Future<void> deleteSellSerialTransactions(BillModel billToDelete) async {
    for (final billItem in billToDelete.items.itemList) {
      final soldSerialNumber = billItem.soldSerialNumber;

      if (soldSerialNumber == null) {
        continue; // Skip if no serial number is linked
      }

      final result = await _serialNumbersRepo.getById(soldSerialNumber);

      result.fold(
        (failure) {
          log('❌ Failed to retrieve serial number [$soldSerialNumber]: ${failure.message}');
        },
        (SerialNumberModel serialsModel) async {
          // Filter out transactions related to the deleted bill
          final updatedTransactions = serialsModel.transactions
              .where((transaction) =>
                  transaction.sellBillId != billToDelete.billId)
              .toList();

          if (updatedTransactions.length == serialsModel.transactions.length) {
            log('🔍 No transactions to delete for serial [$soldSerialNumber].');
            return;
          }

          // Update the serial number model with filtered transactions
          final updatedSerialModel =
              serialsModel.copyWith(transactions: updatedTransactions);

          // Update Firestore or local database with new transaction list
          final updateResult =
              await _serialNumbersRepo.save(updatedSerialModel);

          updateResult.fold(
            (failure) => log(
                '❌ Failed to update transactions for serial [$soldSerialNumber]: ${failure.message}'),
            (success) => log(
                '✅ Successfully removed transactions linked to bill [${billToDelete.billId}] for serial [$soldSerialNumber].'),
          );
        },
      );
    }
  }

  Future<void> deleteBuySerialTransactions(
      BillModel billToDelete, BuildContext context) async {
    final materialController = read<MaterialController>();

    for (final billItem in billToDelete.items.itemList) {
      final materialModel = materialController.getMaterialById(
        billItem.itemGuid,
      );
      final purchaseSerialNumbers = billItem.itemSerialNumbers ?? [];

      if (materialModel.serialNumbers == null) {
        continue; // Skip if material or serial numbers are missing
      }

      final updatedSerialNumbers =
          Map<String, bool>.from(materialModel.serialNumbers!);

      for (final serialNumber in purchaseSerialNumbers) {
        await _processSerialTransaction(
            billToDelete, materialModel, serialNumber, updatedSerialNumbers);
      }
      if (!context.mounted) return;
      // Apply the updated serial numbers to the material model
      materialController.updateMaterialWithChanges(
        materialModel.copyWith(serialNumbers: updatedSerialNumbers),
      );
    }
  }

  /// Processes a single serial number transaction:
  /// Removes it if no transactions remain, or marks it as sold if transactions exist.
  Future<void> _processSerialTransaction(
    BillModel billToDelete,
    MaterialModel materialModel,
    String serialNumber,
    Map<String, bool> updatedSerialNumbers,
  ) async {
    final result = await _serialNumbersRepo.getById(serialNumber);

    await result.fold(
      (failure) async {
        log('❌ Failed to retrieve serial number [$serialNumber]: ${failure.message}');
      },
      (SerialNumberModel serialsModel) async {
        final updatedTransactions = serialsModel.transactions
            .where(
                (transaction) => transaction.buyBillId != billToDelete.billId)
            .toList();

        if (updatedTransactions.length == serialsModel.transactions.length) {
          log('🔍 No purchase transactions to delete for serial [$serialNumber].');
          return;
        }

        if (updatedTransactions.isEmpty) {
          // No transactions remain, so delete the serial document
          await _deleteSerialDocument(
              serialNumber, materialModel, updatedSerialNumbers);
        } else {
          // Update Firestore with filtered transactions
          final updatedSerialModel =
              serialsModel.copyWith(transactions: updatedTransactions);
          final updateResult =
              await _serialNumbersRepo.save(updatedSerialModel);

          await updateResult.fold(
            (failure) async {
              log('❌ Failed to update transactions for serial [$serialNumber]: ${failure.message}');
            },
            (success) async {
              log('✅ Successfully removed purchase transactions linked to bill [${billToDelete.billId}] for serial [$serialNumber].');
              _updateSerialNumberStatus(materialModel, serialNumber,
                  updatedSerialNumbers, updatedTransactions);
            },
          );
        }
      },
    );
  }

  /// Deletes the serial document from Firestore if there are no transactions left.
  Future<void> _deleteSerialDocument(
    String serialNumber,
    MaterialModel materialModel,
    Map<String, bool> updatedSerialNumbers,
  ) async {
    final deleteResult = await _serialNumbersRepo.delete(serialNumber);

    await deleteResult.fold(
      (failure) async {
        log('❌ Failed to delete serial document [$serialNumber]: ${failure.message}');
      },
      (success) async {
        log('🗑️ Serial document [$serialNumber] deleted from Firestore.');
        updatedSerialNumbers.remove(serialNumber); // Remove from materialModel
      },
    );
  }

  /// Updates serial number status based on remaining transactions.
  void _updateSerialNumberStatus(
    MaterialModel materialModel,
    String serialNumber,
    Map<String, bool> updatedSerialNumbers,
    List<SerialTransactionModel> updatedTransactions,
  ) {
    if (updatedTransactions.isEmpty) {
      updatedSerialNumbers.remove(serialNumber);
      log('🗑️ Serial number [$serialNumber] removed from material (${materialModel.matName}).');
    } else {
      updatedSerialNumbers[serialNumber] = true;
      log('✅ Serial number [$serialNumber] of material (${materialModel.matName}) marked as sold.');
    }
  }

  Future<void> saveBill(BillTypeModel billTypeModel,
      {required BuildContext context, required bool withPrint}) async {
    if (saveBillRequestState.value == RequestState.loading) return;
    saveBillRequestState.value = RequestState.loading;

    await _saveOrUpdateBill(
        billTypeModel: billTypeModel, context: context, withPrint: withPrint);
  }

  Future<void> updateBill(
      {required BillTypeModel billTypeModel,
      required BillModel billModel,
      required BuildContext context,
      required withPrint}) async {
    if (saveBillRequestState.value == RequestState.loading) return;

    saveBillRequestState.value = RequestState.loading;
    if (RoleItemType.viewBill.hasUpdatePermission) {
      await _saveOrUpdateBill(
          billTypeModel: billTypeModel,
          existingBill: billModel,
          context: context,
          withPrint: withPrint);
    } else {
      AppUIUtils.onFailure('You do not have permission to update this bill.');
    }
  }

  Future<void> _saveOrUpdateBill(
      {required BuildContext context,
      required BillTypeModel billTypeModel,
      BillModel? existingBill,
      required bool withPrint}) async {
    // Validate the form first

    if (!await validateForm(context)) return;
    if (!context.mounted) return;
    // 2. Create the bill model or handle failure and exit
    final updatedBillModel = await _buildBillModelOrNotifyFailure(
        billTypeModel, existingBill, context);

    if (updatedBillModel == null) {
      saveBillRequestState.value = RequestState.error;
      return;
    }

    // Ensure there are bill items
    if (!_billService.hasModelItems(updatedBillModel.items.itemList)) {
      saveBillRequestState.value = RequestState.error;

      return;
    }

    if (_isNoUpdate(existingBill, updatedBillModel)) {
      saveBillRequestState.value = RequestState.error;

      return;
    }
    if (!context.mounted) return;

    await _saveBillAndHandleResult(
        context, updatedBillModel, existingBill, withPrint);
  }

  /// Checks if there's actually no change from the existing bill.
  bool _isNoUpdate(BillModel? existingBill, BillModel updatedBill) {
    final isNoUpdate = existingBill != null && updatedBill == existingBill;

    if (isNoUpdate) AppUIUtils.onFailure('لم يتم تحديث اي شئ في الفاتورة');
    return isNoUpdate;
  }

  /// Saves the [updatedBill] and handles success/failure UI feedback.
  Future<void> _saveBillAndHandleResult(BuildContext context,
      BillModel updatedBill, BillModel? existingBill, bool withPrint) async {
    final result = await _billsFirebaseRepo.save(updatedBill);

    BillLocalStorageService().saveSingleBill(updatedBill);

    await result.fold(
      (failure) {
        saveBillRequestState.value = RequestState.error;
        AppUIUtils.onFailure(
          failure.message,
        );
      },
      (savedBill) async {
        await _billService.handleSaveOrUpdateSuccess(
          context: context,
          previousBill: existingBill,
          currentBill: savedBill,
          oldBillNumberFromUi: billNumberController.text,
          billSearchController: billSearchController,
          isSave: existingBill == null,
          withPrint: withPrint,
        );
        billNumberController.text = savedBill.billDetails.billNumber.toString();
        saveBillRequestState.value = RequestState.success;
      },
    );
  }

  Future<void> saveSerialNumbers(
    BillModel billModel,
    Map<MaterialModel, List<TextEditingController>> serialControllers,
  ) async {
    // Create a list to collect the serial number models.
    final List<SerialNumberModel> items = [];

    // Iterate through each material's controllers.
    serialControllers.forEach(
      (MaterialModel material, List<TextEditingController> serials) {
        for (final TextEditingController serialController in serials) {
          final serialText = serialController.text.trim();
          log('serialText $serialText');

          // If the text is not empty, create a SerialNumberModel.
          if (serialText.isNotEmpty) {
            final SerialNumberModel serialNumberModel =
                SerialNumberModelFactory.getModel(serialText,
                    billModel: billModel, material: material);
            items.add(serialNumberModel);
          }
        }
      },
    );

    ///matName ipad a16 11 256 pink
    // Save all the serial numbers using your repository.
    final result = await _serialNumbersRepo.saveAll(items);

    // Handle the result of the save operation.
    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (List<SerialNumberModel> savedSerialsModels) =>
          onSaveSerialsSuccess(serialControllers, savedSerialsModels),
    );
  }

  void onSaveSerialsSuccess(
    Map<MaterialModel, List<TextEditingController>> serialControllers,
    List<SerialNumberModel> savedSerialsModels,
  ) {
    serialControllers
        .forEach((MaterialModel material, List<TextEditingController> serials) {
      final materialModel = read<MaterialController>().getMaterialById(
        material.id!,
      );

      for (final serial in savedSerialsModels) {
        log('onSaveSerialsSuccess serial: ${serial.toJson()}');
      }

      // Ensure non-null keys and values
      final Map<String, bool> updatedSerialNumbers = {
        ...?materialModel.serialNumbers, // Preserve existing serials
        for (final serial
            in savedSerialsModels.where((s) => s.matId == material.id))
          if (serial.serialNumber != null &&
              serial.transactions.last.sold != null)
            serial.serialNumber!: serial.transactions.last.sold!,
      };

      // Update the material model with new serial numbers
      read<MaterialController>().updateMaterialWithChanges(
        materialModel.copyWith(serialNumbers: updatedSerialNumbers),
      );
    });
  }

  Future<Either<Failure, BillModel>> updateOnly(BillModel bill) async {
    final result = await _billsFirebaseRepo.save(bill);

    return result;
  }

  appendNewBill(
      {required BillTypeModel billTypeModel,
      required int lastBillNumber,
      int? previousBillNumber}) {
    BillModel newBill = BillModel.empty(
        billTypeModel: billTypeModel,
        lastBillNumber: lastBillNumber,
        previousBillNumber: previousBillNumber);

    billSearchController.insertLastAndUpdate(newBill);
  }

  /// Builds the new [BillModel] from the form data.
  /// If required fields are missing, shows a failure message and returns `null`.
  Future<BillModel?> _buildBillModelOrNotifyFailure(
    BillTypeModel billTypeModel,
    BillModel? existingBill,
    BuildContext context,
  ) async {
    final updatedBillModel =
        _createBillModelFromBillData(billTypeModel, existingBill);

    if (updatedBillModel == null) return null;
    if (existingBill != null) {
      if ((DateTime.now().difference(existingBill.billDetails.billDate!)) >
              Duration(days: 2) &&
          !(RoleItemType.viewBill.hasAdminPermission)) {
        if (await AppUIUtils.askForPassword(context) == false) {
          return null;
        }
      }
    }

    for (BillItem item in updatedBillModel.items.itemList) {
      if (item.itemTotalPrice.toDouble > 99999999) {
        AppUIUtils.onFailure(
          'سعر الاجمالي للقطعة يجب ان لا يتجاوز 99999999',
        );
        return null;
      }
      if (item.itemQuantity > 1000) {
        AppUIUtils.onFailure('اكبر كمية هي 1000');
        return null;
      }
      if ((item.itemGiftsNumber ?? 0) > 1000) {
        AppUIUtils.onFailure(
          'اكبر كمية للهدايا هي 1000',
        );
        return null;
      }
      if (item.itemVatPrice == null || item.itemSubTotalPrice == null) {
        return null;
      }
      if (!AppServiceUtils.isRoughlyEqual(
        (item.itemVatPrice!) + (item.itemSubTotalPrice!),
        (item.itemTotalPrice.toDouble / item.itemQuantity),
      )) {
        AppUIUtils.onFailure(
          'يجب التأكد من قيم الجدول'
          '\n item.Name :\n ${item.itemName}'
          '\n  item.itemQuantity : ${item.itemQuantity} item.itemVatPrice : ${item.itemVatPrice} item.itemSubTotalPrice : ${item.itemSubTotalPrice} item.itemTotalPrice : ${item.itemTotalPrice}'
          '\n (((item.itemVatPrice!) + (item.itemSubTotalPrice!) :${((item.itemVatPrice!) + (item.itemSubTotalPrice!))}'
          '\n (item.itemTotalPrice.toDouble) / item.itemQuantity): ${(item.itemTotalPrice.toDouble) / item.itemQuantity}',
        );
        return null;
      }
      /*if (!billTypeModel.isPurchaseRelated) {
        final currentMat =
            read<MaterialController>().getMaterialById(item.itemGuid);
        log((currentMat.matQuantity).toString(), name: 'matQuantity');
        log((item.itemQuantity).toString(), name: 'itemQuantity');
        log((currentMat.matQuantity! - item.itemQuantity).toString(),
            name: 'currentMat.matQuantity! - item.itemQuantity');
        if (existingBill == null &&
            currentMat.matQuantity! - item.itemQuantity < 0) {
          AppUIUtils.onFailure(
            'لا يمكن بيع المادة ${currentMat.matName} (${currentMat.matQuantity}) كميتها الحالية ',
          );
          if (await AppUIUtils.askForPassword(context) == false) {
            return null;
          }
        } else if(existingBill != null){
          final oldItem = existingBill.items.itemList.firstWhere(
            (e) => e.itemGuid == item.itemGuid,
          );
          int existingQuantity = oldItem.itemQuantity;
          int quantity = item.itemQuantity - existingQuantity;
          if (currentMat.matQuantity! - quantity < 0) {
            AppUIUtils.onFailure(
              'لا يمكن بيع المادة ${currentMat.matName} (${currentMat.matQuantity}) كميتها الحالية ',
            );
            return null;
          }
        }
      }*/
    }

    if (requiredRequestNumber &&
        (updatedBillModel.billDetails.orderNumber == null ||
            updatedBillModel.billDetails.orderNumber!.length < 3)) {
      AppUIUtils.onFailure(
        'من فضلك ادخل رقم الطلب',
      );
      return null;
    }
    if (!(updatedBillModel.billTypeModel.isPurchaseRelated) &&
        ((updatedBillModel.billDetails.customerPhone?.isEmpty) ?? false)) {
      AppUIUtils.onFailure(
        'من فضلك ادخل رقم الزبون',
      );
      return null;
    }

    return updatedBillModel;
  }

  BillModel? _createBillModelFromBillData(BillTypeModel billTypeModel,
      [BillModel? billModel]) {
    // Validate customer and seller accounts
    if (billTypeModel.billPatternType!.hasCashesAccount ||
        billTypeModel.billPatternType!.hasMaterialAccount) {
      if (!_billUtils.validateBillAccount(
        selectedBillAccount,
      )) {
        AppUIUtils.onFailure(
          'من فضلك أدخل اسم العميل !',
        );
        return null;
      }
    }
    if (selectedBillAccount!.id == AppConstants.primaryCashAccountId &&
        selectedPayType.value == InvPayType.due) {
      AppUIUtils.onFailure('لايمكن البيع الاجل للصندوق');
      return null;
    }

    if (!_billUtils.validateSellerAccount(selectedSellerAccount)) {
      AppUIUtils.onFailure(
        'من فضلك أدخل اسم البائع!',
      );
      return null;
    }

    final updatedBillTypeModel = _accountHandler.updateBillTypeAccounts(
          billTypeModel,
          billDetailsPlutoController.generateDiscountsAndAdditions,
          selectedBillAccount,
          selectedStore.value,
        ) ??
        billTypeModel;
    // Create and return the bill model
    return _billService.createBillModel(
      billModel: billModel,
      freeBill: advancedSwitchController.value,
      billNote: noteController.text,
      orderNumber: orderNumberController.text,
      customerPhone: customerPhoneController.text,
      billTypeModel: updatedBillTypeModel,
      billDate: billDate.value,
      billFirstPay: firstPayController.text.toDouble,
      billCustomerId: selectedCustomerAccount?.id! ??
          "00000000-0000-0000-0000-000000000000",
      billAccountId:
          selectedBillAccount?.id! ?? "00000000-0000-0000-0000-000000000000",
      billSellerId: selectedSellerAccount?.costGuid ?? '',
      billPayType: selectedPayType.value.index,
    );
  }

  Future<int> getLastBillNumberForType(BillTypeModel billTypeModel) async {
    int billsCountByType = await getLastNumber(
      category: ApiConstants.bills,
      entityType: billTypeModel.billTypeLabel!,
    );

    return billsCountByType;
  }

  prepareBillRecords(BillItems billItems,
          BillDetailsPlutoController billDetailsPlutoController) async =>
      billDetailsPlutoController.prepareBillMaterialsRows(
        await billItems.getMaterialRecords,
      );

  prepareAdditionsDiscountsRecords(BillModel billModel,
          BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareAdditionsDiscountsRows(
          billModel.getAdditionsDiscountsRecords);

  initCustomerAccount(CustomerModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.name!;
    }
  }

  initBillAccount(AccountModel? account) {
    if (account != null) {
      selectedBillAccount = account;
      billAccountController.text = account.accName!;
    }
  }

  initBillNumberController(int? billNumber) {
    if (billNumber != null) {
      billNumberController.text = billNumber.toString();
    } else {
      billNumberController.text = '';
    }
  }

  void updateBillDetailsOnScreen(
      BillModel bill, BillDetailsPlutoController billPlutoController) async {
    onPayTypeChanged(InvPayType.fromIndex(bill.billDetails.billPayType!));

    setBillDate = bill.billDetails.billDate!;
    isBillSaved.value = bill.billId != null;
    noteController.text = bill.billDetails.billNote ?? '';
    orderNumberController.text = bill.billDetails.orderNumber ?? '';
    customerPhoneController.text = bill.billDetails.customerPhone ?? '';
    firstPayController.text = (bill.billDetails.billFirstPay ?? 0.0).toString();

    initBillNumberController(bill.billDetails.billNumber);
    initCustomerAccount(read<CustomersController>()
        .getCustomerById(bill.billDetails.billCustomerId));
    // initBillAccount(read<AccountsController>().getAccountModelById(AppConstants.primaryCashAccountId));
    initBillAccount(bill.billDetails.billAccountId != null
        ? await read<AccountsController>()
            .getAccountModelByIdAsync(bill.billDetails.billAccountId!)
        : null);
    initFreeLocalSwitcher(bill.freeBill);
    log(bill.freeBill.toString(), name: 'initFreeLocalSwitcher');
    initSellerAccount(sellerId: bill.billDetails.billSellerId);

    await prepareBillRecords(bill.items, billPlutoController);
    prepareAdditionsDiscountsRecords(bill, billPlutoController);
    productsWithTax
        .assignAll(await _billService.getMaterialsWithTax(billModel: bill));

    billPlutoController.update();
  }

  void initSellerAccount({
    required String? sellerId,
  }) {
    final String? billSellerId = sellerId ??
        read<UserManagementController>().loggedInUserModel?.userSellerId;

    if (billSellerId == null) {
      selectedSellerAccount = null;

      sellerAccountController.text = '';
    } else {
      final SellerModel sellerAccount =
          read<SellersController>().getSellerById(billSellerId);

      updateSellerAccount(sellerAccount);

      sellerAccountController.text = sellerAccount.costName!;
    }
  }

  updateSellerAccount(SellerModel? newAccount) {
    if (newAccount != null) {
      selectedSellerAccount = newAccount;
      sellerAccountController.text = newAccount.costName!;
    }
  }

  void generateAndSendBillPdfToEmail(BillModel billModel, BuildContext context,
      {String? recipientEmail}) {
    if (!_billService.hasModelId(billModel.billId)) return;

    if (!_billService.hasModelItems(billModel.items.itemList)) return;

    _billService.generatePdfAndSendToEmail(
      fileName: AppStrings.existedBill.tr,
      itemModel: billModel,
      recipientEmail: recipientEmail,
    );
  }

  void generateAndSaveBillLabel(BillModel billModel, BuildContext context,
      {String? recipientEmail}) async {
    if (!_billService.hasModelId(billModel.billId)) return;

    if (!_billService.hasModelItems(billModel.items.itemList)) return;
    String address = await AppUIUtils.askForCustomerAddress(
      context,
    );

    _billService.generatePdfAndSaveInLocation(
      fileName: AppStrings.existedBill.tr,
      itemModel: DeliveryModel(
          orderDate: billModel.billDetails.billDate!,
          recipientName:
              billModel.billTypeModel.accounts![BillAccounts.caches]!.accName! +
                  billModel.billDetails.orderNumber.toString(),
          phone: billModel.billDetails.customerPhone!,
          address: address,
          orderId: billModel.billDetails.billNumber.toString(),
          items: billModel.items.itemList.toDeliveryItems()),
    );
  }

  Future<void> generateAndSaveBillPdf(BillModel billModel, BuildContext context,
      {String? recipientEmail}) async {
    if (!_billService.hasModelId(billModel.billId)) return;

    if (!_billService.hasModelItems(billModel.items.itemList)) return;

    await _billService.generatePdfAndSaveInLocation(
      fileName: AppStrings.existedBill.tr,
      itemModel: billModel,
    );
  }

  void sendBillToWhatsapp(BillModel billModel, BuildContext context) {
    if (!_billService.hasClientPhoneNumber(context)) return;

    if (!_billService.hasModelId(billModel.billId)) return;

    if (!_billService.hasModelItems(billModel.items.itemList)) return;

    WhatsappService.instance.sendBillToWhatsApp(
        itemModel: billModel,
        recipientPhoneNumber: customerPhoneController.text,
        context: context);
  }

  showEInvoiceDialog(BillModel billModel, BuildContext context) =>
      _billService.showEInvoiceDialog(billModel, context);

  changeBillPlutoView(BillModel billModel, BuildContext context) async {
    if (!await validateForm(context)) return;
    if (!viewBillItemWithTax) {
      productsWithTax.assignAll(await _billService.getMaterialsWithTax(
        billModel: billModel,
      ));
    }
    viewBillItemWithTax = !viewBillItemWithTax;
    update();
  }

  void openFirstPayDialog(BuildContext context) =>
      _billService.showFirstPayDialog(context, firstPayController);

  // Initialize the AdvancedSwitchController with a default value.
  final advancedSwitchController = ValueNotifier(false);

  // Optional: helper method to update the switch value.
  void updateSwitch(bool newValue) {
    advancedSwitchController.value = newValue;
    // You can call update() if you are using GetBuilder or other reactive methods.
    update();
  }

  void initFreeLocalSwitcher(bool? freeBill) {
    advancedSwitchController.value = freeBill ?? false;
  }

  // Copy the filled rows from the Pluto table
  Future<void> copyFilledRowsJson() async {
    final filledRows = billDetailsPlutoController.recordsTableRows
        .where((row) =>
            (row.cells["invRecProduct"]?.value?.toString().trim() ?? "")
                .isNotEmpty &&
            (row.cells["invRecQuantity"]?.value?.toString().trim() ?? "")
                .isNotEmpty)
        .toList();

    Get.find<CopyPasteJsonUseCase>().copy(filledRows);
  }

  // Paste rows from the clipboard into the Pluto table
  Future<void> pasteRowsFromClipboardJson() async {
    try {
      final clipboardData = await Clipboard.getData('text/plain');
      if (clipboardData == null ||
          clipboardData.text == null ||
          clipboardData.text!.isEmpty) return;

      final jsonData = jsonDecode(clipboardData.text!);
      final List<Map<String, dynamic>> rowsData =
          List<Map<String, dynamic>>.from(jsonData['data']);

      debugPrint(rowsData.toString());

      // Keep only rows that have product and quantity filled
      final filledRowsData = rowsData.where((row) {
        final product = (row['invRecProduct'] ?? '').toString().trim();
        final qty = (row['invRecQuantity'] ?? '').toString().trim();
        return product.isNotEmpty && qty.isNotEmpty;
      }).toList();

      if (filledRowsData.isEmpty) return;

      final stateManager = billDetailsPlutoController.recordsTableStateManager;

      // Only include keys that exist in columns
      final validFieldNames = stateManager.columns.map((c) => c.field).toSet();

      final newPlutoRows = filledRowsData.map((rowMap) {
        final cells = <String, PlutoCell>{};

        rowMap.forEach((key, value) {
          if (validFieldNames.contains(key)) {
            // Just create the cell normally; PlutoGrid will link it to the column automatically
            cells[key] = PlutoCell(value: value);
          }
        });

        return PlutoRow(cells: cells);
      }).toList();

      // Insert after the last filled row
      final insertIndex = billDetailsPlutoController.getLastFilledRowIndex();
      stateManager.insertRows(insertIndex, newPlutoRows);

      billDetailsPlutoController.update();
    } catch (e, st) {
      debugPrint("Failed to paste: $e\n$st");
    }
  }

  // Copy only filled rows (product + quantity) to clipboard as XML
  Future<void> copyFilledRows() async {
    final controller = billDetailsPlutoController;

    final materialController = read<MaterialController>();

    // Filter rows that have both product and quantity
    final filledRows = controller.recordsTableRows.where((row) {
      final product =
          row.cells["invRecProduct"]?.value?.toString().trim() ?? "";
      final qty = row.cells["invRecQuantity"]?.value?.toString().trim() ?? "";
      return product.isNotEmpty && qty.isNotEmpty;
    }).toList();

    if (filledRows.isEmpty) return;

    // Convert PlutoRow → MaterialModel
    final matList = filledRows.map((row) {
      final vat = double.tryParse(
        row.cells["invRecVat"]?.value?.toString() ?? '0',
      );

      MaterialModel material = materialController
          .getMaterialByName(row.cells["invRecProduct"]?.value?.toString())!;

      var materialName = material.matName!.replaceAll('\u2063', '');
      material = material.copyWith(
          matQuantity: int.tryParse(
              row.cells["invRecQuantity"]?.value?.toString() ?? '0'),
          matVAT: vat,
          matName: materialName);

      return material;
      // return MaterialModel(
      //   matName: row.cells["invRecProduct"]?.value?.toString(),
      //   matQuantity: int.tryParse(row.cells["invRecQuantity"]?.value?.toString() ?? '0'),
      //   matLastPriceCurVal: double.tryParse(row.cells["invRecPrice"]?.value?.toString() ?? '0'),
      //   // add other fields as needed
      // );
    }).toList();

    // Copy list to clipboard using ClipboardXmlService
    await Get.find<ClipboardXmlService>().copyXmlWithCustom128(matList);
  }

  // Paste rows from XML clipboard into Pluto table
  Future<void> pasteRowsFromClipboard() async {
    try {
      final invoiceRecords = await Get.find<ClipboardXmlService>().paste();

      if (invoiceRecords == null || invoiceRecords.isEmpty) {
        debugPrint("No valid records found");
        return;
      }

      final validRecords = invoiceRecords
          .where(
            (e) =>
                (e.invRecProduct?.trim() ?? '').isNotEmpty &&
                (e.invRecQuantity ?? 0) > 0,
          )
          .toList();

      if (validRecords.isEmpty) return;

      final stateManager = billDetailsPlutoController.recordsTableStateManager;
      final billTypeModel = billDetailsPlutoController.billTypeModel;

      final newRows = validRecords.map((invoice) {
        final cells = invoice.toEditedMap(billTypeModel).map(
              (col, val) => MapEntry(col.field, PlutoCell(value: val)),
            );

        return PlutoRow(cells: cells);
      }).toList();

      final insertIndex = billDetailsPlutoController.getLastFilledRowIndex();

      stateManager.insertRows(insertIndex, newRows);
      billDetailsPlutoController.update();
    } catch (e, st) {
      debugPrint('Failed to paste XML rows: $e\n$st');
    }
  }

  InvoiceRecordModel materialToInvoice(MaterialModel mat) {
    final int quantity = mat.matQuantity ?? 0;
    final double subTotal = mat.calcMinPrice ?? 0.0;
    final double vat = (mat.matVAT ?? 0).toDouble();
    final double total = subTotal * quantity;
    final int giftQty = mat.matBonus ?? 0;
    final double giftTotal = giftQty > 0 ? giftQty * (subTotal + vat) : 0.0;

    return InvoiceRecordModel(
      invRecId: mat.id,
      invRecProduct: mat.matName,
      invRecProductCode: mat.matCode?.toString(),
      invRecQuantity: quantity,
      invRecSubTotal: subTotal,
      invRecVat: vat,
      invRecTotal: total,
      invRecGift: giftQty,
      invRecGiftTotal: giftTotal,
      invRecProductSoldSerial: mat.matForceOutSN?.toString(),
      invRecProductSerialNumbers: mat.serialNumbers?.keys.toList() ?? [],
    );
  }

  showColumnsFilterDialog({required BuildContext context}) {
    launchFloatingWindow(
        context: context,
        minimizedTitle: AppStrings.options,
        floatingScreen: MaterialAttributesDialog(
          billDetailsPlutoController: billDetailsPlutoController,
        ),
        defaultHeight: 100,
        defaultWidth: 300);
  }

  /// this for mobile
  Future<void> printMaterialLabel(BillModel billModel) async {
    final materialController = read<MaterialController>();

    for (final materialRecord in billModel.items.itemList) {
      // 1) جيب المادة
      final MaterialModel? currentModel = await materialController
          .getMaterialByIdWithNull(materialRecord.itemGuid);
/*
      if (currentModel == null) {
        // عدم وجود المادّة: بلّغ وتخطّى هذا السطر
        AppUIUtils.onFailure(
          'بعض المواد غير موجودة \n(${materialRecord.itemGuid} - ${materialRecord.itemName})',
        );
        continue;
      }*/

      final dynamic qtyRaw = materialRecord.itemQuantity;
      int copies;

      if (qtyRaw is int) {
        copies = qtyRaw;
      } else if (qtyRaw is double) {
        copies = qtyRaw.round();
      } else {
        copies = int.tryParse('$qtyRaw') ?? 1;
      }

      // ضمان المجال (على سبيل المثال 1..500)
      copies = copies.clamp(1, 500);

      // 3) اطبع
      await materialController.printMaterialBarcode(
        material: currentModel!,
        copies: copies,
      );
    }
  }

  /// this for mobile
/*showBarCodeScanner(BuildContext context, BillTypeModel billTypeModel) => _billService.showBarCodeScanner(
      context: context,
      stateManager: billDetailsPlutoController.recordsTableStateManager,
      plutoController: billDetailsPlutoController,
      billTypeModel: billTypeModel);*/
}
