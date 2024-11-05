import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/features/invoice/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/classes/repositories/firebase_repo_base.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/utils/generate_id.dart';
import '../../../core/utils/utils.dart';
import '../../accounts/data/models/account_model.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../../print/controller/print_controller.dart';
import '../../print/data/repositories/translation_repository.dart';
import '../data/models/invoice_record_model.dart';

class InvoiceController extends GetxController with AppValidator {
  final FirebaseRepositoryBase<BillTypeModel> _patternsRepo;
  final FirebaseRepositoryBase<BillModel> _billsRepo;

  final TranslationRepository _translationRepository;

  InvoiceController(this._patternsRepo, this._billsRepo, this._translationRepository);

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

  @override
  void onInit() {
    super.onInit();

    // selectedCustomerAccount = AccountModel(id: '5b36c82d-9105-4177-a5c3-0f90e5857e3c', accName: 'الصندوق');

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
      // updateCustomerAccount(payType);
      update();
    }
  }

  // updateCustomerAccount(InvPayType payType) {
  //   switch (payType) {
  //     case InvPayType.cash:
  //       final String customerAccountName = invCustomerAccountController.text;
  //       Get.find<AccountsController>().customerAccount = AccountModel();
  //
  //       break;
  //     case InvPayType.due:
  //       customerAccount = billType == BillType.sales ? CustomerAccount.cashCustomer : CustomerAccount.provider;
  //       invCustomerAccountController.text = customerAccount.label;
  //       break;
  //   }
  // }

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
