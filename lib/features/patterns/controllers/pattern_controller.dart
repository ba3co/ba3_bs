import 'package:ba3_bs/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base_classes/interface_repository.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../data/models/bill_type_model.dart';
import '../ui/widgets/pattern_source_code.dart';

class PatternController extends GetxController with AppValidator {
  final IRepository<BillTypeModel> _repository;

  PatternController(this._repository);

  PatternRecordDataSource? recordViewDataSource;
  TextEditingController latinShortNameController = TextEditingController();
  TextEditingController latinFullNameController = TextEditingController();
  TextEditingController shortNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController primaryController = TextEditingController();
  TextEditingController giftsController = TextEditingController();
  TextEditingController exchangeForGiftsController = TextEditingController();
  TextEditingController typeController = TextEditingController();
  TextEditingController discountsController = TextEditingController();
  TextEditingController materialsController = TextEditingController();
  TextEditingController additionsController = TextEditingController();
  TextEditingController cachesController = TextEditingController();
  TextEditingController storeController = TextEditingController();

  bool hasVatController = false;

  final formKey = GlobalKey<FormState>();

  RxMap<String, BillTypeModel> patternModel = <String, BillTypeModel>{}.obs;

  List<String> accountPickList = [];

  BillTypeModel? editPatternModel;

  InvoiceType selectedBillType = InvoiceType.buy;

  int? selectedColorValue;

  RxBool isLoading = false.obs;

  bool validateForm() => formKey.currentState!.validate();

  void onMainColorChanged(int? newColorValue) {
    selectedColorValue = newColorValue;
    update();
  }

  void onSelectedTypeChanged(InvoiceType? newType) {
    if (newType != null) {
      selectedBillType = newType;
      update();
    }
  }

  addNewPattern() async {
    if (!validateForm()) return;

    isLoading.value = true;

    final billTypeModel = _createBillTypeModel();

    final result = await _repository.save(billTypeModel);

    result.fold((failure) => Utils.showSnackBar('خطأ', failure.message),
        (success) => Utils.showSnackBar('نجاح', 'تم حفظ النموذج بنجاح!'));

    isLoading.value = false;
  }

  BillTypeModel _createBillTypeModel() => BillTypeModel(
        shortName: shortNameController.text,
        latinShortName: latinShortNameController.text,
        fullName: fullNameController.text,
        latinFullName: latinFullNameController.text,
        billType: selectedBillType.label,
        materialAccount: materialsController.text,
        discountsAccount: discountsController.text,
        additionsAccount: additionsController.text,
        cashesAccount: cachesController.text,
        giftsAccount: giftsController.text,
        exchangeForGiftsAccount: exchangeForGiftsController.text,
        store: storeController.text,
        color: selectedColorValue,
      );

  String? validator(String? value, String fieldName) => isFieldValid(value, fieldName);
}
