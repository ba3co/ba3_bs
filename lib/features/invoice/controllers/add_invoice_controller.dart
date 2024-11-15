import 'dart:developer';

import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:ba3_bs/features/invoice/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/abstract/i_firebase_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../../core/utils/generate_id.dart';
import '../../accounts/data/models/account_model.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../../print/controller/print_controller.dart';
import '../data/models/invoice_record_model.dart';
import '../services/invoice/invoice_service.dart';
import 'invoice_pluto_controller.dart';

class AddInvoiceController extends GetxController with AppValidator {
  // Repositories
  final IFirebaseRepository<BillModel> _billsFirebaseRepo;

  AddInvoiceController(this._billsFirebaseRepo);

  // Services
  late final InvoiceService _invoiceService;

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

  // Initializer
  void _initializeServices() {
    _invoiceService = InvoiceService();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    setBillDate(DateTime.now());
  }

  bool validateForm() => formKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  String get invId => generateId(RecordType.invoice);

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

  Future<void> fetchBills() async {
    final result = await _billsFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBills) => bills.assignAll(fetchedBills),
    );

    isLoading = false;
    update();
  }

  Future<void> deleteBill(String billId) async {
    final result = await _billsFirebaseRepo.delete(billId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!'),
    );

    Get.offAllNamed(AppRoutes.mainLayout);
  }

  Future<void> printInvoice(List<InvoiceRecordModel> invRecords) async {
    await Get.find<PrintingController>().startPrinting(invRecords: invRecords, invId: invId, invDate: billDate);
  }

  void createBond(BillTypeModel billTypeModel) {
    if (!validateForm()) return;

    _invoiceService.createBond(billTypeModel: billTypeModel, customerAccount: selectedCustomerAccount!);
  }

  Future<void> saveBill({required BillTypeModel billTypeModel, BillModel? billModel, bool isEdit = false}) async {
    if (!validateForm()) return;

    final updatedBillModel = _createBillModelFromInvoiceData(billModel, billTypeModel);

    if (updatedBillModel == null) {
      AppUIUtils.onFailure('من فضلك أدخل اسم العميل واسم البائع!');
      return;
    }

    final result = await _billsFirebaseRepo.save(updatedBillModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => _onSaveBillSuccess(isEdit, billTypeModel),
    );
  }

  Future<void> _onSaveBillSuccess(bool isEdit, BillTypeModel billTypeModel) async {
    AppUIUtils.onSuccess(isEdit ? 'تم تعديل الفاتورة بنجاح!' : 'تم حفظ الفاتورة بنجاح!');
    _resetInvoiceForm(billTypeModel);
    if (isEdit) {
      await fetchBills();
      Get.until(ModalRoute.withName(AppRoutes.showAllBillsScreen));
    }
  }

  BillModel? _createBillModelFromInvoiceData(BillModel? billModel, BillTypeModel billTypeModel) {
    final updatedBillTypeModel = _updateBillTypeAccounts(billTypeModel) ?? billTypeModel;

    SellerController sellerController = Get.find<SellerController>();

    if (selectedCustomerAccount == null || sellerController.selectedSellerAccount == null) {
      return null;
    }
    log('billDate $billDate');
    log('accName ${selectedCustomerAccount?.accName}');
    log('billPayType ${selectedPayType.index}');

    return _invoiceService.createBillModel(
      billModel: billModel,
      billTypeModel: updatedBillTypeModel,
      billDate: billDate,
      billCustomerId: selectedCustomerAccount!.id!,
      billSellerId: sellerController.selectedSellerAccount!.costGuid!,
      billPayType: selectedPayType.index,
    );
  }

  BillTypeModel? _updateBillTypeAccounts(BillTypeModel billTypeModel) {
    final selectedAccounts = selectedAdditionsDiscountAccounts;
    final updatedAccounts = {...billTypeModel.accounts ?? {}};

    if (_noUpdateNeeded(selectedAccounts, selectedCustomerAccount)) return null;

    _updateDiscountAndAdditionAccounts(selectedAccounts, updatedAccounts);

    _updateCachesAccount(selectedCustomerAccount, updatedAccounts);

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

  updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value) =>
      selectedAdditionsDiscountAccounts[key] = value;

  void navigateToAllBillsScreen() => Get.toNamed(AppRoutes.showAllBillsScreen);

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  initBillNumberController(int? billNumber) {
    if (billNumber != null) {
      billNumberController.text = billNumber.toString();
    } else {
      billNumberController.text = '';
    }
  }

  void initSellerAccount(String billSellerId) => Get.find<SellerController>().initSellerAccount(billSellerId);

  void _resetInvoiceForm(BillTypeModel billTypeModel) {
    // Clear all material and additions/discounts records in InvoicePlutoController
    Get.find<InvoicePlutoController>()
      ..prepareMaterialsRows([])
      ..prepareAdditionsDiscountsRows([])
      ..update();

    sellerAccountController.clear();

    update();
  }

  Future<void> onBackPressed(String billTypeId) async {
    InvoiceController invoiceController = Get.find<InvoiceController>();

    invoiceController.openLastBillDetails(billTypeId);
  }
}
