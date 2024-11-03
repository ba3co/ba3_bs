import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/classes/repositories/firebase_repo_base.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/utils/utils.dart';
import '../../accounts/data/models/account_model.dart';
import '../../patterns/data/models/bill_type_model.dart';

class InvoiceController extends GetxController with AppValidator {
  final FirebaseRepositoryBase<BillTypeModel> _repository;

  InvoiceController(this._repository);

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

    billDate = DateTime.now().toString().split(".")[0];
  }

  bool validateForm() => formKey.currentState!.validate();

  updateBillType(String billTypeLabel) {
    billType = BillType.fromLabel(billTypeLabel);
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
    final result = await _repository.getAll();

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
}
