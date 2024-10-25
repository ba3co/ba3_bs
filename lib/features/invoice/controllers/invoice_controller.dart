import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/base_classes/repositories/base_repo.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/utils/utils.dart';
import '../../patterns/data/models/bill_type_model.dart';

class InvoiceController extends GetxController {
  final BaseRepository<BillTypeModel> _repository;

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

  String? billDate;
  List<BillTypeModel> billsTypes = [];
  InvPayType selectedPayType = InvPayType.cash;

  @override
  void onInit() {
    super.onInit();
    getAllBillTypes();
    billDate = DateTime.now().toString().split(".")[0];
  }

  onPayTypeChanged(InvPayType? newType) {
    if (newType != null) {
      selectedPayType = newType;
      update();
    }
  }

  Future<void> getAllBillTypes() async {
    final result = await _repository.getAll();

    result.fold(
      (failure) {
        Utils.showSnackBar('خطأ', failure.message);
      },
      (fetchedBillTypes) {
        debugPrint('fetchedBillTypes ${fetchedBillTypes.length}');
        billsTypes.assignAll(fetchedBillTypes);
      },
    );
    update();
  }
}
