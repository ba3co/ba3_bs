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

  updateBillType(String billTypeLabel) {
    billType = BillType.fromLabel(billTypeLabel);
  }

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

  void navigateToAllBillsScreen() {
    Get.toNamed(AppRoutes.showAllBillsScreen);
  }

  void navigateToBillDetailsScreen(
      {required String billId, required String customerAccName, required String sellerAccName}) {
    Get.lazyPut(() => InvoicePlutoController());
    BillModel billModel = getBillFromId(billId);

    // Convert list of BillItem to list of InvoiceRecordModel
    List<InvoiceRecordModel> invRecords = InvoiceRecordModel.fromBillItemList(billModel.items.itemList);

    // Load the rows in the InvoicePlutoController and navigate to the Bill Details screen
    Get.find<InvoicePlutoController>().loadMainPlutoTableRowsFromInvRecords(invRecords);

    AccountModel customerAcc = billModel.billTypeModel.accounts![BillAccounts.caches]!;

    Get.find<InvoicePlutoController>()
        .loadAdditionsDiscountsPlutoTableRowsFromInvRecords(getAdditionsDiscountsRecords(billModel.billDetails));
    initCustomerAccount(customerAcc);
    Get.toNamed(AppRoutes.billDetailsScreen, arguments: {
      'billModel': billModel,
      'customerAcc': customerAcc,
      'sellerAccName': sellerAccName,
    });
  }

  List<Map<String, String>> getAdditionsDiscountsRecords(BillDetails billDetails) {
    double billTotal = billDetails.billTotal ?? 0;

    String billAdditionsTotalStr = (billDetails.billAdditionsTotal != null && billDetails.billAdditionsTotal != 0)
        ? billDetails.billAdditionsTotal.toString()
        : '';

    String billDiscountsTotalStr = (billDetails.billDiscountsTotal != null && billDetails.billDiscountsTotal != 0)
        ? billDetails.billDiscountsTotal.toString()
        : '';

    // Helper function for ratio calculation
    double calculateRatio(double value, double total) => total != 0 ? (value / total) * 100 : 0;

    // Calculate ratios
    double billAdditionsRatio = calculateRatio(billDetails.billAdditionsTotal ?? 0, billTotal);
    double billDiscountsRatio = calculateRatio(billDetails.billDiscountsTotal ?? 0, billTotal);

    // Construct and return the list of records
    return [
      {
        'accountId': 'الحسم الممنوح',
        'discountId': billDiscountsTotalStr,
        'discountRatioId': billDiscountsRatio.toStringAsFixed(0),
        'additionId': '',
        'additionRatioId': '',
      },
      {
        'accountId': 'الاضافات',
        'discountId': '',
        'discountRatioId': '',
        'additionId': billAdditionsTotalStr,
        'additionRatioId': billAdditionsRatio.toStringAsFixed(0),
      }
    ];
  }

  BillModel getBillFromId(String billId) {
    return bills.firstWhere((bill) => bill.billId == billId);
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

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);

  Future<void> addNewInvoice({
    required double billTotal,
    required double billVatTotal,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required BillTypeModel billTypeModel,
    required List<InvoiceRecordModel> billItems,
  }) async {
    if (!validateForm()) return;

    final billModel = _createBillModel(
      billPayType: selectedPayType.index,
      billDate: billDate!,
      customerId: selectedCustomerAccount!.id!,
      sellerId: Get.find<SellerController>().selectedSellerAccount!.costGuid!,
      billTotal: billTotal,
      billVatTotal: billVatTotal,
      billGiftsTotal: billGiftsTotal,
      billDiscountsTotal: billDiscountsTotal,
      billAdditionsTotal: billAdditionsTotal,
      billTypeModel: billTypeModel,
      billItems: billItems,
    );

    final result = await _billsRepo.save(billModel);

    result.fold((failure) => Utils.showSnackBar('خطأ', failure.message),
        (success) => Utils.showSnackBar('نجاح', 'تم حفظ الفاتورة بنجاح!'));
  }

  BillModel _createBillModel({
    String? note,
    int? billNumber,
    required int billPayType,
    required String billDate,
    required String customerId,
    required String sellerId,
    required double billVatTotal,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required double billTotal,
    required BillTypeModel billTypeModel,
    required List<InvoiceRecordModel> billItems,
  }) {
    return BillModel(
      billTypeModel: billTypeModel,
      billDetails: BillDetails(
        note: note,
        billDate: billDate,
        billNumber: billNumber,
        billPayType: billPayType,
        billSellerId: sellerId,
        billCustomerId: customerId,
        billTotal: billTotal,
        billVatTotal: billVatTotal,
        billGiftsTotal: billGiftsTotal,
        billDiscountsTotal: billDiscountsTotal,
        billAdditionsTotal: billAdditionsTotal,
      ),
      items: BillItems(
          itemList: billItems
              .map((invoiceRecordModel) => BillItem(
                    itemGuid: invoiceRecordModel.invRecId!,
                    itemName: invoiceRecordModel.invRecProduct!,
                    itemQuantity: invoiceRecordModel.invRecQuantity!,
                    itemTotalPrice: invoiceRecordModel.invRecTotal.toString(),
                    itemSubTotalPrice: invoiceRecordModel.invRecSubTotal,
                    itemVatPrice: invoiceRecordModel.invRecVat,
                    itemGiftsPrice: invoiceRecordModel.invRecGiftTotal,
                    itemGiftsNumber: invoiceRecordModel.invRecGift,
                  ))
              .toList()),
    );
  }

  Future<void> printInvoice(List<InvoiceRecordModel> invRecords) async {
    PrintingController printController = Get.find<PrintingController>();

    await printController.startPrinting(invRecords: invRecords, invId: invId, invDate: billDate!);
  }

  String get invId => generateId(RecordType.invoice);
}
