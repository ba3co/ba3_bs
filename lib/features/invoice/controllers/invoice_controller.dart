import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/features/invoice/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/classes/repositories/firebase_repo_base.dart';
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
  final FirebaseRepositoryBase<BillTypeModel> _patternsRepo;
  final FirebaseRepositoryBase<BillModel> _billsRepo;

  InvoiceController(this._patternsRepo, this._billsRepo);

  final TextEditingController invCodeController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController storeController = TextEditingController();
  final TextEditingController customerAccountController = TextEditingController();
  final TextEditingController sellerAccountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final TextEditingController firstPayController = TextEditingController();
  final TextEditingController invReturnDateController = TextEditingController();
  final TextEditingController invReturnCodeController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String? billDate;

  List<BillTypeModel> billsTypes = [];

  AccountModel? selectedCustomerAccount;

  InvPayType selectedPayType = InvPayType.cash;
  BillType billType = BillType.sales;

  List<BillModel> bills = [];

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();

    getAllBillTypes();

    setBillDate(DateTime.now());
  }

  bool validateForm() => formKey.currentState!.validate();

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  String get invId => generateId(RecordType.invoice);

  updateBillType(String billTypeLabel) => billType = BillType.byLabel(billTypeLabel);

  void setBillDate(DateTime newDate) {
    billDate = newDate.toString().split(" ")[0];
    update();
  }

  onPayTypeChanged(InvPayType? payType) {
    if (payType != null) {
      selectedPayType = payType;
      update();
    }
  }

  updateCustomerAccount(AccountModel? newAccount) {
    if (newAccount != null) {
      selectedCustomerAccount = newAccount;
    }
  }

  Future<void> fetchBills() async {
    final result = await _billsRepo.getAll();

    result.fold(
      (failure) {
        Utils.showSnackBar('خطأ', failure.message);
      },
      (fetchedBills) {
        bills.assignAll(fetchedBills);
      },
    );
    isLoading = false;
    update();
  }

  Future<void> getAllBillTypes() async {
    final result = await _patternsRepo.getAll();

    result.fold(
      (failure) {
        Utils.showSnackBar('خطأ', failure.message);
      },
      (fetchedBillTypes) {
        billsTypes.assignAll(fetchedBillTypes);
      },
    );
    update();
  }

  Future<void> saveBill({required BillTypeModel billTypeModel, BillModel? billModel, bool isEdit = false}) async {
    if (!validateForm()) return;

    final updatedBillModel = _createBillModelFromInvoiceData(billModel: billModel, billTypeModel: billTypeModel);

    final result = await _billsRepo.save(updatedBillModel);

    // Display appropriate success message based on the operation type
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
    final result = await _billsRepo.delete(billId);

    result.fold((failure) => Utils.showSnackBar('خطأ', failure.message),
        (success) => Utils.showSnackBar('نجاح', 'تم حذف الفاتورة بنجاح!'));

    Get.offAllNamed(AppRoutes.mainLayout);
  }

  Future<void> printInvoice(List<InvoiceRecordModel> invRecords) async =>
      await Get.find<PrintingController>().startPrinting(invRecords: invRecords, invId: invId, invDate: billDate!);

  void createBond(BillTypeModel billTypeModel) {
    if (!validateForm()) return;

    final BondController bondController = Get.find<BondController>();
    final InvoicePlutoController invoicePlutoController = Get.find<InvoicePlutoController>();

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

  BillModel _createBillModelFromInvoiceData({BillModel? billModel, required BillTypeModel billTypeModel}) {
    final InvoicePlutoController invoicePlutoController = Get.find<InvoicePlutoController>();

    return BillModel.fromInvoiceData(
      billModel: billModel,
      billTypeModel: billTypeModel,
      note: null,
      billNumber: null,
      billCustomerId: selectedCustomerAccount!.id!,
      billSellerId: Get.find<SellerController>().selectedSellerAccount!.costGuid!,
      billPayType: selectedPayType.index,
      billDate: billDate!,
      billTotal: invoicePlutoController.calculateFinalTotal,
      billVatTotal: invoicePlutoController.computeTotalVat,
      billWithoutVatTotal: invoicePlutoController.computeWithoutVatTotal,
      billGiftsTotal: invoicePlutoController.computeGifts,
      billDiscountsTotal: invoicePlutoController.computeDiscounts,
      billAdditionsTotal: invoicePlutoController.computeAdditions,
      billItems: invoicePlutoController.handleSaveAllMaterials(),
    );
  }

  BillModel getBillById(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  void navigateToAllBillsScreen() => Get.toNamed(AppRoutes.showAllBillsScreen);

  void navigateToBillDetailsScreen(String billId) {
    _initializeInvoiceController();

    final InvoicePlutoController invoicePlutoController = Get.find<InvoicePlutoController>();

    final BillModel billModel = getBillById(billId);

    _prepareInvoiceRecords(billModel.items, invoicePlutoController);

    _prepareAdditionsDiscountsRecords(billModel.billDetails, invoicePlutoController);

    _initializeCustomerAccount(billModel);

    _initializeSellerAccount(billModel);

    Get.toNamed(
      AppRoutes.billDetailsScreen,
      arguments: {'billModel': billModel},
    );
  }

  void _initializeInvoiceController() => Get.lazyPut(() => InvoicePlutoController());

  _prepareInvoiceRecords(BillItems billItems, InvoicePlutoController invoiceController) =>
      invoiceController.loadMainTableRows(billItems.materialRecords);

  _prepareAdditionsDiscountsRecords(BillDetails billDetails, InvoicePlutoController invoicePlutoController) =>
      invoicePlutoController.loadAdditionsDiscountsRows(billDetails.additionsDiscountsRecords);

  void _initializeCustomerAccount(BillModel billModel) {
    final AccountModel customerAcc = billModel.billTypeModel.accounts![BillAccounts.caches]!;

    initCustomerAccount(customerAcc);
  }

  void _initializeSellerAccount(BillModel billModel) {
    final SellerModel sellerAcc = Get.find<SellerController>().getSellerById(billModel.billDetails.billSellerId!);

    initSellerAccount(sellerAcc);
  }

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      customerAccountController.text = account.accName!;
    }
  }

  initSellerAccount(SellerModel sellerAcc) {
    Get.find<SellerController>().initSellerAccount(sellerAcc);

    sellerAccountController.text = sellerAcc.costName!;
  }
}

// 300
