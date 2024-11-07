import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/features/invoice/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/classes/repositories/firebase_repo_base.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/utils/generate_id.dart';
import '../../../core/utils/utils.dart';
import '../../accounts/data/models/account_model.dart';
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
  final TextEditingController invCustomerAccountController = TextEditingController();
  final TextEditingController sellerController = TextEditingController();
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

  updateBillType(String billTypeLabel) => billType = BillType.fromLabel(billTypeLabel);

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

  initCustomerAccount(AccountModel? account) {
    if (account != null) {
      selectedCustomerAccount = account;
      invCustomerAccountController.text = account.accName!;
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

  Future<void> deleteInvoice(String billId) async {
    final result = await _billsRepo.delete(billId);

    result.fold((failure) => Utils.showSnackBar('خطأ', failure.message),
        (success) => Utils.showSnackBar('نجاح', 'تم حذف الفاتورة بنجاح!'));

    Get.offAllNamed(AppRoutes.mainLayout);
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

  Future<void> addNewInvoice(BillModel billModel) async {
    if (!validateForm()) return;

    // Create a modified copy of the billModel
    final updatedBillModel = billModel.copyWith(
      billDetails: billModel.billDetails.copyWith(
        note: null,
        billNumber: null,
        billCustomerId: selectedCustomerAccount!.id!,
        billSellerId: Get.find<SellerController>().selectedSellerAccount!.costGuid!,
        billPayType: selectedPayType.index,
        billDate: billDate!,
      ),
    );

    final result = await _billsRepo.save(updatedBillModel);

    result.fold((failure) => Utils.showSnackBar('خطأ', failure.message),
        (success) => Utils.showSnackBar('نجاح', 'تم حفظ الفاتورة بنجاح!'));
  }

  Future<void> printInvoice(List<InvoiceRecordModel> invRecords) async =>
      await Get.find<PrintingController>().startPrinting(invRecords: invRecords, invId: invId, invDate: billDate!);

  BillModel getBillFromId(String billId) => bills.firstWhere((bill) => bill.billId == billId);

  void navigateToAllBillsScreen() => Get.toNamed(AppRoutes.showAllBillsScreen);

  void navigateToBillDetailsScreen(
      {required String billId, required String customerAccName, required String sellerAccName}) {
    _initializeInvoiceController();

    final InvoicePlutoController invoicePlutoController = Get.find<InvoicePlutoController>();

    final BillModel billModel = getBillFromId(billId);

    _prepareInvoiceRecords(billModel.items, invoicePlutoController);

    _prepareAdditionsDiscountsRecords(billModel.billDetails, invoicePlutoController);

    final AccountModel customerAccount = _initializeCustomerAccount(billModel);

    Get.toNamed(
      AppRoutes.billDetailsScreen,
      arguments: {'billModel': billModel, 'customerAcc': customerAccount, 'sellerAccName': sellerAccName},
    );
  }

  void _initializeInvoiceController() => Get.lazyPut(() => InvoicePlutoController());

  _prepareInvoiceRecords(BillItems billItems, InvoicePlutoController invoiceController) =>
      invoiceController.loadMainTableRows(billItems.materialRecords);

  _prepareAdditionsDiscountsRecords(BillDetails billDetails, InvoicePlutoController invoicePlutoController) =>
      invoicePlutoController.loadAdditionsDiscountsRows(billDetails.additionsDiscountsRecords);

  AccountModel _initializeCustomerAccount(BillModel billModel) {
    final AccountModel customerAcc = billModel.billTypeModel.accounts![BillAccounts.caches]!;

    initCustomerAccount(customerAcc);
    return customerAcc;
  }
}

// 300
