import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/features/invoice/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/classes/base/i_firebase_repo.dart';
import '../../../core/classes/concrete/json_export_repository.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/generate_id.dart';
import '../../../core/utils/utils.dart';
import '../../accounts/data/models/account_model.dart';
import '../../bond/controllers/bond_controller.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../../print/controller/print_controller.dart';
import '../data/models/invoice_record_model.dart';
import 'invoice_pluto_controller.dart';

class InvoiceController extends GetxController with AppValidator {
  final IFirebaseRepository<BillTypeModel> _patternsFirebaseRepo;
  final IFirebaseRepository<BillModel> _billsFirebaseRepo;
  final JsonExportRepository<BillModel> _invoiceRepo;

  final formKey = GlobalKey<FormState>();
  final TextEditingController invCodeController = TextEditingController();
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

  InvoiceController(this._patternsFirebaseRepo, this._billsFirebaseRepo, this._invoiceRepo);

  @override
  void onInit() {
    super.onInit();
    getAllBillTypes();
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

  Future<void> fetchBills() async {
    final result = await _billsFirebaseRepo.getAll();
    result.fold(
      (failure) => Utils.showSnackBar('خطأ', failure.message),
      (fetchedBills) => bills.assignAll(fetchedBills),
    );
    isLoading = false;
    update();
  }

  Future<void> getAllBillTypes() async {
    final result = await _patternsFirebaseRepo.getAll();
    result.fold(
      (failure) => Utils.showSnackBar('خطأ', failure.message),
      (fetchedBillTypes) => billsTypes.assignAll(fetchedBillTypes),
    );
    update();
  }

  Future<void> saveBill({required BillTypeModel billTypeModel, BillModel? billModel, bool isEdit = false}) async {
    if (!validateForm()) return;
    final updatedBillModel = _createBillModelFromInvoiceData(billModel, billTypeModel);

    final result = await _billsFirebaseRepo.save(updatedBillModel);
    final successMessage = isEdit ? 'تم تعديل الفاتورة بنجاح!' : 'تم حفظ الفاتورة بنجاح!';

    result.fold(
      (failure) => Utils.showSnackBar('خطأ', failure.message),
      (success) => Utils.showSnackBar('نجاح', successMessage),
    );

    if (isEdit) {
      await fetchBills();
      Get.until(ModalRoute.withName(AppRoutes.showAllBillsScreen));
    }
  }

  Future<void> deleteBill(String billId) async {
    final result = await _billsFirebaseRepo.delete(billId);
    result.fold(
      (failure) => Utils.showSnackBar('خطأ', failure.message),
      (success) => Utils.showSnackBar('نجاح', 'تم حذف الفاتورة بنجاح!'),
    );
    Get.offAllNamed(AppRoutes.mainLayout);
  }

  Future<void> printInvoice(List<InvoiceRecordModel> invRecords) async {
    await Get.find<PrintingController>().startPrinting(invRecords: invRecords, invId: invId, invDate: billDate);
  }

  Future<void> exportBillsJsonFile() async {
    if (bills.isEmpty) return;
    final result = await _invoiceRepo.exportJsonFile(bills);

    result.fold(
      (failure) => Utils.showSnackBar('خطأ', failure.message),
      (success) => Utils.showSnackBar('نجاح', 'تم تصدير الفواتير بنجاح!'),
    );
  }

  void createBond(BillTypeModel billTypeModel) {
    if (!validateForm()) return;
    final bondController = Get.find<BondController>();
    final invoicePlutoController = Get.find<InvoicePlutoController>();

    bondController.createBond(
      billTypeModel: billTypeModel,
      vat: invoicePlutoController.computeTotalVat,
      customerAccount: selectedCustomerAccount!,
      total: invoicePlutoController.computeWithoutVatTotal,
      gifts: invoicePlutoController.computeGifts,
      discount: invoicePlutoController.computeDiscounts,
      addition: invoicePlutoController.computeAdditions,
    );
  }

  BillModel _createBillModelFromInvoiceData(BillModel? billModel, BillTypeModel billTypeModel) {
    final invoicePlutoController = Get.find<InvoicePlutoController>();
    final updatedBillTypeModel = _updateBillTypeAccounts(billTypeModel);

    return BillModel.fromInvoiceData(
      billModel: billModel,
      billTypeModel: updatedBillTypeModel ?? billTypeModel,
      note: null,
      billNumber: null,
      billCustomerId: selectedCustomerAccount!.id!,
      billSellerId: Get.find<SellerController>().selectedSellerAccount!.costGuid!,
      billPayType: selectedPayType.index,
      billDate: billDate,
      billTotal: invoicePlutoController.calculateFinalTotal,
      billVatTotal: invoicePlutoController.computeTotalVat,
      billWithoutVatTotal: invoicePlutoController.computeWithoutVatTotal,
      billGiftsTotal: invoicePlutoController.computeGifts,
      billDiscountsTotal: invoicePlutoController.computeDiscounts,
      billAdditionsTotal: invoicePlutoController.computeAdditions,
      billItems: invoicePlutoController.handleSaveAllMaterials(),
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

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  void navigateToAllBillsScreen() => Get.toNamed(AppRoutes.showAllBillsScreen);

  void navigateToBillDetailsScreen(String billId) {
    _initializeInvoiceController();

    final InvoicePlutoController invoicePlutoController = Get.find<InvoicePlutoController>();

    final BillModel billModel = getBillById(billId);

    _prepareInvoiceRecords(billModel.items, invoicePlutoController);

    _prepareAdditionsDiscountsRecords(billModel, invoicePlutoController);

    _initializeCustomerAccount(billModel);

    _initializeSellerAccount(billModel);

    Get.toNamed(AppRoutes.billDetailsScreen, arguments: {'billModel': billModel});
  }

  void _initializeInvoiceController() => Get.lazyPut(() => InvoicePlutoController());

  _prepareInvoiceRecords(BillItems billItems, InvoicePlutoController invoicePlutoController) =>
      invoicePlutoController.prepareItems(billItems.materialRecords);

  _prepareAdditionsDiscountsRecords(BillModel billModel, InvoicePlutoController invoicePlutoController) =>
      invoicePlutoController.prepareAdditionsDiscounts(billModel.additionsDiscountsRecords);

  void _initializeCustomerAccount(BillModel billModel) {
    final AccountModel customerAcc = billModel.billTypeModel.accounts![BillAccounts.caches]!;

    initCustomerAccount(customerAcc);
  }

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  void _initializeSellerAccount(BillModel billModel) {
    final sellerController = Get.find<SellerController>();
    final SellerModel sellerAcc = sellerController.getSellerById(billModel.billDetails.billSellerId!);

    sellerController.initSellerAccount(sellerAcc);

    sellerAccountController.text = sellerAcc.costName!;
  }

  updateSelectedAdditionsDiscountAccounts(Account key, AccountModel value) {
    selectedAdditionsDiscountAccounts[key] = value;
  }
}

// 300

// 193
