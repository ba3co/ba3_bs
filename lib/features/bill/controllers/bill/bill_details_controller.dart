import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_model_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/interfaces/i_store_selection_handler.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/queryable_savable_repo.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/bill/services/bill/bill_local_storage_service.dart';
import 'package:ba3_bs/features/bill/services/bill/bill_utils.dart';
import 'package:ba3_bs/features/customer/controllers/customers_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/custom_alert_dialog/helper_alert.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/whatsapp/whatsapp_service.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../customer/data/models/customer_model.dart';
import '../../../materials/controllers/material_controller.dart';
import '../../../materials/data/models/materials/material_model.dart';
import '../../../materials/service/serial_number_model_factory.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../print/controller/print_controller.dart';
import '../../../sellers/data/models/seller_model.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../../users_management/data/models/role_model.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/invoice_record_model.dart';
import '../../data/models/product_with_tax_model.dart';
import '../../services/bill/account_handler.dart';
import '../../services/bill/bill_details_service.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillDetailsController extends IBillController
    with AppValidator, AppNavigator, FirestoreSequentialNumbers
    implements IStoreSelectionHandler {
  // Repositories

  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;

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
  final TextEditingController customerAccountController = TextEditingController();
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

  Rx<bool> get isAccountReadOnly => (selectedPayType.value == InvPayType.cash).obs;

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
  void updateCustomerAccount(CustomerModel? newAccount, BillTypeModel billTypeModel) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
      customerAccountController.text = newAccount.name!;
      if (billTypeModel.isPurchaseRelated && newAccount.customerHasVat != true) {
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

  bool get requiredRequestNumber => selectedBillAccount?.requiredRequestNumber ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void updateBillType(String billTypeLabel) => billType = BillType.byLabel(billTypeLabel);

  set setBillDate(DateTime newDate) {
    billDate.value = newDate;
    //   update();
  }

  void onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType.value = payType;
      if (payType == InvPayType.cash) {
        final primaryCashAccount = read<AccountsController>().getAccountModelById(AppConstants.primaryCashAccountId);
        updateBillAccount(primaryCashAccount);
      }
      log('onPayTypeChanged');
    }
  }

  Future<void> printBill(
      {required BuildContext context, required BillModel billModel, required List<InvoiceRecordModel> invRecords}) async {
    if (!_billService.hasModelId(billModel.billId)) return;

    await read<PrintingController>().startPrinting(
      context: context,
      invRecords: invRecords,
      billNumber: billModel.billDetails.billNumber!,
      invDate: billDate.value.dayMonthYear,
    );
  }

  void launchFloatingEntryBondDetailsScreen(BillModel billModel, BuildContext context) async {
    if (!await validateForm(context)) return;
    if (!context.mounted) return;
    _billService.launchFloatingEntryBondDetailsScreen(
      context: context,
      billModel: billModel,
    );
  }

  void updateBillStatus(BillModel billModel, newStatus, BuildContext context) async {
    if (billModel.items.itemList.map((e) => e.itemName).contains('الباركود خطأ')) {
      AppUIUtils.onFailure(
        'لا يمكن تغيير حالة الفاتورة بسبب وجود باركود خطأ',
      );
      return;
    } else {
      final result = await _billsFirebaseRepo.save(billModel.copyWith(status: newStatus));

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
  Future<bool> _hasSoldSerialNumbers(BillModel billModel, BuildContext context) async {
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
          ? serialsModel.transactions.where((transaction) => transaction.sold ?? false).last.sellBillNumber
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
          final updatedTransactions =
              serialsModel.transactions.where((transaction) => transaction.sellBillId != billToDelete.billId).toList();

          if (updatedTransactions.length == serialsModel.transactions.length) {
            log('🔍 No transactions to delete for serial [$soldSerialNumber].');
            return;
          }

          // Update the serial number model with filtered transactions
          final updatedSerialModel = serialsModel.copyWith(transactions: updatedTransactions);

          // Update Firestore or local database with new transaction list
          final updateResult = await _serialNumbersRepo.save(updatedSerialModel);

          updateResult.fold(
            (failure) => log('❌ Failed to update transactions for serial [$soldSerialNumber]: ${failure.message}'),
            (success) => log('✅ Successfully removed transactions linked to bill [${billToDelete.billId}] for serial [$soldSerialNumber].'),
          );
        },
      );
    }
  }

  Future<void> deleteBuySerialTransactions(BillModel billToDelete, BuildContext context) async {
    final materialController = read<MaterialController>();

    for (final billItem in billToDelete.items.itemList) {
      final materialModel = materialController.getMaterialById(
        billItem.itemGuid,
      );
      final purchaseSerialNumbers = billItem.itemSerialNumbers ?? [];

      if (materialModel.serialNumbers == null) {
        continue; // Skip if material or serial numbers are missing
      }

      final updatedSerialNumbers = Map<String, bool>.from(materialModel.serialNumbers!);

      for (final serialNumber in purchaseSerialNumbers) {
        await _processSerialTransaction(billToDelete, materialModel, serialNumber, updatedSerialNumbers);
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
        final updatedTransactions = serialsModel.transactions.where((transaction) => transaction.buyBillId != billToDelete.billId).toList();

        if (updatedTransactions.length == serialsModel.transactions.length) {
          log('🔍 No purchase transactions to delete for serial [$serialNumber].');
          return;
        }

        if (updatedTransactions.isEmpty) {
          // No transactions remain, so delete the serial document
          await _deleteSerialDocument(serialNumber, materialModel, updatedSerialNumbers);
        } else {
          // Update Firestore with filtered transactions
          final updatedSerialModel = serialsModel.copyWith(transactions: updatedTransactions);
          final updateResult = await _serialNumbersRepo.save(updatedSerialModel);

          await updateResult.fold(
            (failure) async {
              log('❌ Failed to update transactions for serial [$serialNumber]: ${failure.message}');
            },
            (success) async {
              log('✅ Successfully removed purchase transactions linked to bill [${billToDelete.billId}] for serial [$serialNumber].');
              _updateSerialNumberStatus(materialModel, serialNumber, updatedSerialNumbers, updatedTransactions);
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

  Future<void> saveBill(BillTypeModel billTypeModel, {required BuildContext context, required bool withPrint}) async {
    await _saveOrUpdateBill(billTypeModel: billTypeModel, context: context, withPrint: withPrint);
  }

  Future<void> updateBill(
      {required BillTypeModel billTypeModel, required BillModel billModel, required BuildContext context, required withPrint}) async {
    if (RoleItemType.viewBill.hasUpdatePermission) {
      await _saveOrUpdateBill(billTypeModel: billTypeModel, existingBill: billModel, context: context, withPrint: withPrint);
    } else {
      AppUIUtils.onFailure('You do not have permission to update this bill.');
    }
  }

  Future<void> _saveOrUpdateBill(
      {required BuildContext context, required BillTypeModel billTypeModel, BillModel? existingBill, required bool withPrint}) async {
    // Validate the form first

    if (!await validateForm(context)) return;

    // 2. Create the bill model or handle failure and exit
    final updatedBillModel = _buildBillModelOrNotifyFailure(billTypeModel, existingBill);

    if (updatedBillModel == null) return;

    // Ensure there are bill items
    if (!_billService.hasModelItems(updatedBillModel.items.itemList)) return;

    if (_isNoUpdate(existingBill, updatedBillModel)) return;

    if (!context.mounted) return;

    await _saveBillAndHandleResult(context, updatedBillModel, existingBill, withPrint);
  }

  /// Checks if there's actually no change from the existing bill.
  bool _isNoUpdate(BillModel? existingBill, BillModel updatedBill) {
    final isNoUpdate = existingBill != null && updatedBill == existingBill;

    if (isNoUpdate) AppUIUtils.onFailure('لم يتم تحديث اي شئ في الفاتورة');
    return isNoUpdate;
  }

  /// Saves the [updatedBill] and handles success/failure UI feedback.
  Future<void> _saveBillAndHandleResult(BuildContext context, BillModel updatedBill, BillModel? existingBill, bool withPrint) async {
    saveBillRequestState.value = RequestState.loading;

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
          billSearchController: billSearchController,
          isSave: existingBill == null,
          withPrint: withPrint,
        );

        saveBillRequestState.value = RequestState.success;
      },
    );
  }

  Future<void> saveSerialNumbers(
    BillModel billModel,
    Map<MaterialModel, List<TextEditingController>> serialControllers,
  ) async {
    log('saveSerialNumbers $serialControllers');

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
                SerialNumberModelFactory.getModel(serialText, billModel: billModel, material: material);
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
      (List<SerialNumberModel> savedSerialsModels) => onSaveSerialsSuccess(serialControllers, savedSerialsModels),
    );
  }

  void onSaveSerialsSuccess(
    Map<MaterialModel, List<TextEditingController>> serialControllers,
    List<SerialNumberModel> savedSerialsModels,
  ) {
    serialControllers.forEach((MaterialModel material, List<TextEditingController> serials) {
      final materialModel = read<MaterialController>().getMaterialById(
        material.id!,
      );

      for (final serial in savedSerialsModels) {
        log('onSaveSerialsSuccess serial: ${serial.toJson()}');
      }

      // Ensure non-null keys and values
      final Map<String, bool> updatedSerialNumbers = {
        ...?materialModel.serialNumbers, // Preserve existing serials
        for (final serial in savedSerialsModels.where((s) => s.matId == material.id))
          if (serial.serialNumber != null && serial.transactions.last.sold != null) serial.serialNumber!: serial.transactions.last.sold!,
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

  appendNewBill({required BillTypeModel billTypeModel, required int lastBillNumber, int? previousBillNumber}) {
    BillModel newBill =
        BillModel.empty(billTypeModel: billTypeModel, lastBillNumber: lastBillNumber, previousBillNumber: previousBillNumber);

    billSearchController.insertLastAndUpdate(newBill);
  }

  /// Builds the new [BillModel] from the form data.
  /// If required fields are missing, shows a failure message and returns `null`.
  BillModel? _buildBillModelOrNotifyFailure(BillTypeModel billTypeModel, BillModel? existingBill) {
    final updatedBillModel = _createBillModelFromBillData(billTypeModel, existingBill);

    if (updatedBillModel == null) return null;

    for (BillItem item in updatedBillModel.items.itemList) {
      if (item.itemTotalPrice.toDouble > 99999999) {
        AppUIUtils.onFailure(
          'سعر الاجمالي للقطعة يجب ان لا يتجاوز 99999999',
        );
        return null;
      }
      if (item.itemQuantity > 100) {
        AppUIUtils.onFailure('اكبر كمية هي 100');
        return null;
      }
      if ((item.itemGiftsNumber ?? 0) > 20) {
        AppUIUtils.onFailure(
          'اكبر كمية للهدايا هي 20',
        );
        return null;
      }
      if ((item.itemQuantity * ((item.itemVatPrice ?? 0) + (item.itemSubTotalPrice ?? 0))).floor() !=
          item.itemTotalPrice.toDouble.floor()) {
        AppUIUtils.onFailure(
          'يجب التأكد من قيم الجدول',
        );
        return null;
      }
    }

    if (requiredRequestNumber &&
        (updatedBillModel.billDetails.orderNumber == null || updatedBillModel.billDetails.orderNumber!.length < 3)) {
      AppUIUtils.onFailure(
        'من فضلك ادخل رقم الطلب',
      );
      return null;
    }

    return updatedBillModel;
  }

  BillModel? _createBillModelFromBillData(BillTypeModel billTypeModel, [BillModel? billModel]) {
    // Validate customer and seller accounts
    if (billTypeModel.billPatternType!.hasCashesAccount || billTypeModel.billPatternType!.hasMaterialAccount) {
      if (!_billUtils.validateBillAccount(
        selectedBillAccount,
      )) {
        AppUIUtils.onFailure(
          'من فضلك أدخل اسم العميل !',
        );
        return null;
      }
    }
    if (selectedBillAccount!.id == AppConstants.primaryCashAccountId && selectedPayType.value == InvPayType.due) {
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
      billCustomerId: selectedCustomerAccount?.id! ?? "00000000-0000-0000-0000-000000000000",
      billAccountId: selectedBillAccount?.id! ?? "00000000-0000-0000-0000-000000000000",
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

  prepareBillRecords(BillItems billItems, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareBillMaterialsRows(
        billItems.getMaterialRecords,
      );

  prepareAdditionsDiscountsRecords(BillModel billModel, BillDetailsPlutoController billDetailsPlutoController) =>
      billDetailsPlutoController.prepareAdditionsDiscountsRows(billModel.getAdditionsDiscountsRecords);

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

  void updateBillDetailsOnScreen(BillModel bill, BillDetailsPlutoController billPlutoController) async {
    onPayTypeChanged(InvPayType.fromIndex(bill.billDetails.billPayType!));

    setBillDate = bill.billDetails.billDate!;
    isBillSaved.value = bill.billId != null;
    noteController.text = bill.billDetails.billNote ?? '';
    orderNumberController.text = bill.billDetails.orderNumber ?? '';
    customerPhoneController.text = bill.billDetails.customerPhone ?? '';
    firstPayController.text = (bill.billDetails.billFirstPay ?? 0.0).toString();

    initBillNumberController(bill.billDetails.billNumber);
    initCustomerAccount(read<CustomersController>().getCustomerById(bill.billDetails.billCustomerId));
    initBillAccount(read<AccountsController>().getAccountModelById(AppConstants.primaryCashAccountId));
    initFreeLocalSwitcher(bill.freeBill);

    initSellerAccount(sellerId: bill.billDetails.billSellerId);

    prepareBillRecords(bill.items, billPlutoController);
    prepareAdditionsDiscountsRecords(bill, billPlutoController);
    productsWithTax.assignAll(await _billService.getMaterialsWithTax(billModel: bill));

    billPlutoController.update();
  }

  void initSellerAccount({
    required String? sellerId,
  }) {
    final String? billSellerId = sellerId ?? read<UserManagementController>().loggedInUserModel?.userSellerId;

    if (billSellerId == null) {
      selectedSellerAccount = null;

      sellerAccountController.text = '';
    } else {
      final SellerModel sellerAccount = read<SellersController>().getSellerById(billSellerId);

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

  void generateAndSendBillPdfToEmail(BillModel billModel, BuildContext context, {String? recipientEmail}) {
    if (!_billService.hasModelId(billModel.billId)) return;

    if (!_billService.hasModelItems(billModel.items.itemList)) return;

    _billService.generatePdfAndSendToEmail(
      fileName: AppStrings.existedBill.tr,
      itemModel: billModel,
      recipientEmail: recipientEmail,
    );
  }

  void sendBillToWhatsapp(BillModel billModel, BuildContext context) {
    if (!_billService.hasClientPhoneNumber(context)) return;

    if (!_billService.hasModelId(billModel.billId)) return;

    if (!_billService.hasModelItems(billModel.items.itemList)) return;

    WhatsappService.instance.sendBillToWhatsApp(itemModel: billModel, recipientPhoneNumber: customerPhoneController.text, context: context);
  }

  showEInvoiceDialog(BillModel billModel, BuildContext context) => _billService.showEInvoiceDialog(billModel, context);

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

  void openFirstPayDialog(BuildContext context) => _billService.showFirstPayDialog(context, firstPayController);

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

  /// this for mobile
/*showBarCodeScanner(BuildContext context, BillTypeModel billTypeModel) => _billService.showBarCodeScanner(
      context: context,
      stateManager: billDetailsPlutoController.recordsTableStateManager,
      plutoController: billDetailsPlutoController,
      billTypeModel: billTypeModel);*/
}