import 'package:ba3_bs/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/base_classes/repositories/base_repo.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../data/models/bill_type_model.dart';

class PatternController extends GetxController with AppValidator {
  final BaseRepository<BillTypeModel> _repository;

  PatternController(this._repository);

  TextEditingController latinShortNameController = TextEditingController();
  TextEditingController latinFullNameController = TextEditingController();
  TextEditingController shortNameController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController giftsController = TextEditingController();
  TextEditingController exchangeForGiftsController = TextEditingController();
  TextEditingController discountsController = TextEditingController();
  TextEditingController materialsController = TextEditingController();
  TextEditingController additionsController = TextEditingController();
  TextEditingController cachesController = TextEditingController();
  TextEditingController storeController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  InvoiceType selectedBillType = InvoiceType.buy;

  int selectedColorValue = Colors.red.value;

  bool validateForm() => formKey.currentState!.validate();

  List<BillTypeModel> billsTypes = [];

  void onMainColorChanged(int? newColorValue) {
    if (newColorValue != null) {
      selectedColorValue = newColorValue;
      update();
    }
  }

  void onSelectedTypeChanged(InvoiceType? newType) {
    if (newType != null) {
      selectedBillType = newType;
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
        billsTypes.assignAll(fetchedBillTypes);
      },
    );
  }

  addNewPattern() async {
    if (!validateForm()) return;

    final billTypeModel = _createBillTypeModel();

    final result = await _repository.save(billTypeModel);

    result.fold((failure) => Utils.showSnackBar('خطأ', failure.message),
        (success) => Utils.showSnackBar('نجاح', 'تم حفظ النموذج بنجاح!'));
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
