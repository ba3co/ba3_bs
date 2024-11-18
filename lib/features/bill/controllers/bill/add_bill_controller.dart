import 'dart:developer';

import 'package:ba3_bs/core/controllers/abstract/i_bill_controller.dart';
import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/core/services/firebase/abstract/firebase_repo_with_result_base.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/abstract/i_selected_store_controller.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../../print/controller/print_controller.dart';
import '../../data/models/invoice_record_model.dart';
import '../../services/bill/bill_service.dart';
import 'all_bills_controller.dart';
import 'bill_details_controller.dart';
import 'bill_search_controller.dart';

class AddBillController extends GetxController with AppValidator implements IBillController, IStoreSelectionHandler {
  // Repositories
  final FirebaseRepositoryWithResultBase<BillModel> _billsFirebaseRepo;

  AddBillController(this._billsFirebaseRepo);

  // Services
  late final BillService _billService;

  final formKey = GlobalKey<FormState>();

  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  late String billDate;
  AccountModel? selectedCustomerAccount;
  InvPayType selectedPayType = InvPayType.cash;
  BillType billType = BillType.sales;
  List<BillModel> bills = [];
  bool isLoading = true;

  Map<Account, AccountModel> selectedAdditionsDiscountAccounts = {};

  RxBool showAddNewBillButton = false.obs;

  int? lastBillAddedNumber;

  @override
  updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value) =>
      selectedAdditionsDiscountAccounts[key] = value;

  @override
  StoreAccount selectedStore = StoreAccount.main;

  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) {
      selectedStore = newStore;
      update();
    }
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    setBillDate(DateTime.now());
  }

  // Initializer
  void _initializeServices() {
    _billService = BillService(Get.find<AddBillPlutoController>());
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  void updateBillType(String billTypeLabel) => billType = BillType.byLabel(billTypeLabel);

  void setBillDate(DateTime newDate) {
    billDate = newDate.toString().split(" ")[0];
    update();
  }

  void onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType = payType;
      update();
    }
  }

  void updateCustomerAccount(AccountModel? newAccount) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
    }
  }

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  Future<void> printInvoice(List<InvoiceRecordModel> invRecords) async {
    log('lastBillAddedNumber $lastBillAddedNumber');
    if (!_hasBillItems(invRecords)) return;

    if (!_hasBillNumber()) return;

    await Get.find<PrintingController>()
        .startPrinting(invRecords: invRecords, billNumber: lastBillAddedNumber!, invDate: billDate);
  }

  void createBond(BillTypeModel billTypeModel) {
    if (!validateForm()) return;

    _billService.createBond(billTypeModel: billTypeModel, customerAccount: selectedCustomerAccount!);
  }

  Future<void> saveBill(BillTypeModel billTypeModel) async {
    // Validate the form first
    if (!validateForm()) return;

    // Create the bill model from the provided invoice data
    final BillModel? updatedBillModel = _createBillModelFromInvoiceData(billTypeModel);

    // Return if the model creation failed
    if (updatedBillModel == null) return;

    // Check if the bill items are not empty
    if (!_hasBillItems(updatedBillModel.items.itemList)) return;

    // Save the bill to Firestore
    final result = await _billsFirebaseRepo.save(updatedBillModel);

    // Handle the result (success or failure)
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (billModel) => _handleSaveSuccess(billModel.billDetails.billNumber!),
    );
  }

  bool _hasBillItems(List items) {
    if (items.isEmpty) {
      AppUIUtils.onFailure('يرجى إضافة عنصر واحد على الأقل إلى الفاتورة!');
      return false;
    }
    return true;
  }

  bool _hasBillNumber() {
    if (lastBillAddedNumber == null) {
      AppUIUtils.onFailure('يرجى إضافة الفاتورة أولا قبل طباعتها!');
      return false;
    }
    return true;
  }

  BillModel? _createBillModelFromInvoiceData(BillTypeModel billTypeModel) {
    final updatedBillTypeModel = _updateBillTypeAccounts(billTypeModel) ?? billTypeModel;
    final sellerController = Get.find<SellerController>();

    // Validate customer and seller accounts
    if (!_validateCustomerAccount() || !_validateSellerAccount(sellerController)) {
      return null;
    }

    // Create and return the bill model
    return _billService.createBillModel(
      billTypeModel: updatedBillTypeModel,
      billDate: billDate,
      billCustomerId: selectedCustomerAccount!.id!,
      billSellerId: sellerController.selectedSellerAccount!.costGuid!,
      billPayType: selectedPayType.index,
    );
  }

  bool _validateCustomerAccount() {
    if (selectedCustomerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل!');
      return false;
    }
    return true;
  }

  bool _validateSellerAccount(SellerController sellerController) {
    if (sellerController.selectedSellerAccount == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم البائع!');
      return false;
    }
    return true;
  }

  BillTypeModel? _updateBillTypeAccounts(BillTypeModel billTypeModel) {
    final selectedAccounts = selectedAdditionsDiscountAccounts;
    final updatedAccounts = {...billTypeModel.accounts ?? {}};

    if (_noUpdateNeeded(selectedAccounts, selectedCustomerAccount)) return null;

    _updateDiscountAndAdditionAccounts(selectedAccounts, updatedAccounts);

    _updateCachesAccount(selectedCustomerAccount, updatedAccounts);

    _updateStoreAccount(selectedStore, updatedAccounts);

    return billTypeModel.copyWith(accounts: updatedAccounts);
  }

  // Return null if there is Additions and Discounts Accounts not updated and no selected customer account
  bool _noUpdateNeeded(Map<Account, AccountModel> selectedAccounts, AccountModel? selectedCustomerAccount) =>
      selectedAccounts.isEmpty && selectedCustomerAccount == null;

  // Update discount and addition accounts
  void _updateDiscountAndAdditionAccounts(
      Map<Account, AccountModel> selectedAccounts, Map<Account, AccountModel> updatedAccounts) {
    if (selectedAccounts.isNotEmpty) {
      if (selectedAccounts.containsKey(BillAccounts.discounts)) {
        updatedAccounts[BillAccounts.discounts] = selectedAccounts[BillAccounts.discounts]!;
      }
      if (selectedAccounts.containsKey(BillAccounts.additions)) {
        updatedAccounts[BillAccounts.additions] = selectedAccounts[BillAccounts.additions]!;
      }
    }
  }

  // Update caches account if selectedCustomerAccount is not null and differs from the current cache
  void _updateCachesAccount(AccountModel? selectedCustomerAccount, Map<Account, AccountModel> updatedAccounts) {
    if (selectedCustomerAccount != null && updatedAccounts[BillAccounts.caches]?.id != selectedCustomerAccount.id) {
      updatedAccounts[BillAccounts.caches] = selectedCustomerAccount;
    }
  }

  // Update store account if selectedStore is not null and differs from the current store
  void _updateStoreAccount(StoreAccount? selectedStore, Map<Account, AccountModel> updatedAccounts) {
    if (selectedStore != null && updatedAccounts[BillAccounts.store]?.id != selectedStore.typeGuide) {
      updatedAccounts[BillAccounts.store] = selectedStore.toStoreAccountModel;
    }
  }

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  void initSellerAccount(String billSellerId) => Get.find<SellerController>().initSellerAccount(billSellerId);

  Future<void> _handleSaveSuccess(int billNumber) async {
    AppUIUtils.onSuccess('تم حفظ الفاتورة بنجاح!');

    _updateLastBillAddedNumber(billNumber);

    _toggleShowAddNewBillButton(true);
  }

  _updateLastBillAddedNumber(int? newBillNumber) {
    lastBillAddedNumber = newBillNumber;
  }

  _toggleShowAddNewBillButton(newValue) {
    showAddNewBillButton.value = newValue;
  }

  void resetBillForm() {
    Get.find<AddBillPlutoController>().resetAllTables();

    sellerAccountController.clear();

    _updateLastBillAddedNumber(null);

    _toggleShowAddNewBillButton(false);
  }

  Future<void> onBackPressed(String billTypeId) async {
    AllBillsController allBillsController = Get.find<AllBillsController>();

    await allBillsController.fetchBills();

    List<BillModel> billsByCategory = allBillsController.getBillsByType(billTypeId);

    final BillModel lastBill = billsByCategory.last;

    Get.find<BillDetailsController>().updateScreenWithBillData(lastBill);

    Get.find<BillSearchController>().initSearchControllerBill(billsByCategory: billsByCategory, bill: lastBill);

    Get.back();
  }
}
