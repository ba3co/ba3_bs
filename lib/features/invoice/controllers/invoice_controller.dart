import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_search_controller.dart';
import 'package:ba3_bs/features/invoice/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/abstract/i_firebase_repo.dart';
import '../../../core/services/json_file_operations/implementations/export/json_export_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../../core/utils/generate_id.dart';
import '../../accounts/data/models/account_model.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../../print/controller/print_controller.dart';
import '../data/models/bill_items.dart';
import '../data/models/invoice_record_model.dart';
import '../services/invoice/invoice_service.dart';
import '../services/invoice/invoice_utils.dart';
import 'invoice_pluto_controller.dart';

class InvoiceController extends GetxController with AppValidator {
  // Repositories
  final IFirebaseRepository<BillTypeModel> _patternsFirebaseRepo;
  final IFirebaseRepository<BillModel> _billsFirebaseRepo;
  final JsonExportRepository<BillModel> _jsonExportRepo;

  // Services
  late final InvoiceService _invoiceService;
  late final InvoiceUtils _invoiceUtils;

  final formKey = GlobalKey<FormState>();
  final TextEditingController billNumberController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController firstPayController = TextEditingController();
  final TextEditingController invReturnDateController = TextEditingController();
  final TextEditingController invReturnCodeController = TextEditingController();

  late String billDate;
  List<BillTypeModel> billsTypes = [];
  AccountModel? selectedCustomerAccount;
  InvPayType selectedPayType = InvPayType.cash;
  BillType billType = BillType.sales;
  List<BillModel> bills = [];
  bool isLoading = true;

  Map<Account, AccountModel> selectedAdditionsDiscountAccounts = {};

  InvoiceController(this._patternsFirebaseRepo, this._billsFirebaseRepo, this._jsonExportRepo);

  // Initializer
  void _initializeServices() {
    _invoiceService = InvoiceService();
    _invoiceUtils = InvoiceUtils();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();

    setBillDate(DateTime.now());

    getAllBillTypes();
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

  Future<void> getAllBillTypes() async {
    final result = await _patternsFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBillTypes) => billsTypes.assignAll(fetchedBillTypes),
    );

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

  Future<void> exportBillsJsonFile() async {
    if (bills.isEmpty) {
      AppUIUtils.onFailure('لا توجد فواتير للتصدير');
      return;
    }

    final result = await _jsonExportRepo.exportJsonFile(bills);

    result.fold(
      (failure) => AppUIUtils.onFailure('فشل في تصدير الملف [${failure.message}]'),
      (filePath) => _invoiceUtils.showExportSuccessDialog(filePath),
    );
  }

  void createBond(BillTypeModel billTypeModel) {
    if (!validateForm()) return;

    _invoiceService.createBond(billTypeModel);
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
      (_) => _onSaveBillSuccess(isEdit),
    );
  }

  Future<void> _onSaveBillSuccess(bool isEdit) async {
    AppUIUtils.onSuccess(isEdit ? 'تم تعديل الفاتورة بنجاح!' : 'تم حفظ الفاتورة بنجاح!');
    if (isEdit) {
      await fetchBills();
      Get.until(ModalRoute.withName(AppRoutes.showAllBillsScreen));
    }
  }

  BillModel? _createBillModelFromInvoiceData(BillModel? billModel, BillTypeModel billTypeModel) {
    final updatedBillTypeModel = _updateBillTypeAccounts(billTypeModel) ?? billTypeModel;

    return _invoiceService.createBillModel(billModel, updatedBillTypeModel);
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

  void navigateToBillDetailsScreen(String billId) {
    final BillModel billModel = getBillById(billId);

    _updateScreenWithCurrentBill(billModel);

    _initInvoiceSearchController(billModel);

    Get.toNamed(AppRoutes.billDetailsScreen);
  }

  prepareInvoiceRecords(BillItems billItems, InvoicePlutoController invoicePlutoController) =>
      invoicePlutoController.prepareMaterialsRows(billItems.materialRecords);

  prepareAdditionsDiscountsRecords(BillModel billModel, InvoicePlutoController invoicePlutoController) =>
      invoicePlutoController.prepareAdditionsDiscountsRows(billModel.additionsDiscountsRecords);

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

  List<BillModel> getBillsByType(String billTypeId) =>
      bills.where((bill) => bill.billTypeModel.billTypeId == billTypeId).toList();

  void initSellerAccount(String billSellerId) => Get.find<SellerController>().initSellerAccount(billSellerId);

  void _updateScreenWithCurrentBill(BillModel bill) {
    InvoicePlutoController invoicePlutoController = Get.putIfAbsent(InvoicePlutoController());

    onPayTypeChanged(InvPayType.fromIndex(bill.billDetails.billPayType!));

    setBillDate(bill.billDetails.billDate!.toDate!);

    initBillNumberController(bill.billDetails.billNumber);

    initCustomerAccount(bill.billTypeModel.accounts?[BillAccounts.caches]);
    initSellerAccount(bill.billDetails.billSellerId!);

    prepareInvoiceRecords(bill.items, invoicePlutoController);
    prepareAdditionsDiscountsRecords(bill, invoicePlutoController);
  }

  // Update `_initInvoiceSearchController` to use `Get.putIfAbsent`:
  void _initInvoiceSearchController(BillModel bill) {
    List<BillModel> billsByCategory = getBillsByType(bill.billTypeModel.billTypeId!);

    Get.putIfAbsent(InvoiceSearchController()).initSearchControllerBill(billsByCategory: billsByCategory, bill: bill);
  }
}

// 300

// 193
