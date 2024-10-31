import 'package:ba3_bs/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/classes/repositories/firebase_repo_base.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../data/models/bill_type_model.dart';

class PatternController extends GetxController with AppValidator {
  final FirebaseRepositoryBase<BillTypeModel> _repository;

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

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    autoFillControllers(InvoiceType.buy);
  }

  void onMainColorChanged(int? newColorValue) {
    if (newColorValue != null) {
      selectedColorValue = newColorValue;
      update();
    }
  }

  void onSelectedTypeChanged(InvoiceType? newType) {
    if (newType != null) {
      selectedBillType = newType;
      autoFillControllers(newType);
      update();
    }
  }

  void autoFillControllers(InvoiceType newType) {
    // Clear previous values
    clearControllers();

    switch (newType) {
      case InvoiceType.sales:
        fillControllers(
            materials: SalesAccounts.sales.label,
            caches: SalesAccounts.cashBox.label,
            exchangeForGifts: SalesAccounts.settlements.label,
            gifts: SalesAccounts.salesGifts.label,
            discounts: SalesAccounts.grantedDiscount.label,
            additions: SalesAccounts.differentRevenues.label,
            shortName: 'مبيعات',
            fullName: 'فاتورة مبيعات',
            latinShortName: 'Sales',
            latinFullName: 'Sales Invoice');
        break;

      case InvoiceType.buy:
        fillControllers(
            materials: BuyAccounts.purchases.label,
            caches: BuyAccounts.cashBox.label,
            exchangeForGifts: BuyAccounts.settlements.label,
            gifts: BuyAccounts.purchaseGifts.label,
            discounts: BuyAccounts.earnedDiscount.label,
            additions: BuyAccounts.differentExpenses.label,
            shortName: 'شراء',
            fullName: 'فاتورة مشتريات',
            latinShortName: 'Buy',
            latinFullName: 'Purchase Invoice');
        break;

      case InvoiceType.add:
        fillControllers(
            materials: BuyAccounts.purchases.label,
            caches: BuyAccounts.cashBox.label,
            exchangeForGifts: BuyAccounts.settlements.label,
            gifts: BuyAccounts.purchaseGifts.label,
            discounts: BuyAccounts.earnedDiscount.label,
            additions: BuyAccounts.differentExpenses.label,
            shortName: 'إضافة',
            fullName: 'فاتورة إضافة',
            latinShortName: 'Add',
            latinFullName: 'Addition Invoice');
        break;

      case InvoiceType.remove:
        fillControllers(
            materials: SalesAccounts.sales.label,
            caches: SalesAccounts.cashBox.label,
            exchangeForGifts: SalesAccounts.settlements.label,
            gifts: SalesAccounts.salesGifts.label,
            discounts: SalesAccounts.grantedDiscount.label,
            additions: SalesAccounts.differentRevenues.label,
            shortName: 'سحب',
            fullName: 'فاتورة سحب',
            latinShortName: 'Remove',
            latinFullName: 'Removal Invoice');
        break;

      case InvoiceType.buyReturn:
        fillControllers(
            materials: SalesAccounts.sales.label,
            caches: SalesAccounts.cashBox.label,
            exchangeForGifts: 'تسويات',
            gifts: SalesAccounts.salesGifts.label,
            discounts: SalesAccounts.grantedDiscount.label,
            additions: SalesAccounts.differentRevenues.label,
            shortName: 'مرتجع شراء',
            fullName: 'فاتورة مرتجع مشتريات',
            latinShortName: 'Return Buy',
            latinFullName: 'Purchase Return Invoice');
        break;

      case InvoiceType.salesReturn:
        fillControllers(
            materials: BuyAccounts.purchases.label,
            caches: BuyAccounts.cashBox.label,
            exchangeForGifts: BuyAccounts.settlements.label,
            gifts: BuyAccounts.purchaseGifts.label,
            discounts: BuyAccounts.earnedDiscount.label,
            additions: BuyAccounts.differentExpenses.label,
            shortName: 'مرتجع مبيعات',
            fullName: 'فاتورة مرتجع مبيعات',
            latinShortName: 'Return Sales',
            latinFullName: 'Sales Return Invoice');
        break;
    }
  }

  void fillControllers({
    required String materials,
    required String caches,
    required String exchangeForGifts,
    required String gifts,
    required String discounts,
    required String additions,
    required String shortName,
    required String fullName,
    required String latinShortName,
    required String latinFullName,
  }) {
    materialsController.text = materials;
    cachesController.text = caches;
    discountsController.text = discounts;
    additionsController.text = additions;
    giftsController.text = gifts;
    exchangeForGiftsController.text = exchangeForGifts;

    shortNameController.text = shortName;
    fullNameController.text = fullName;
    latinShortNameController.text = latinShortName;
    latinFullNameController.text = latinFullName;

    update();
  }

  void clearControllers() {
    materialsController.clear();
    cachesController.clear();
    discountsController.clear();
    additionsController.clear();
    giftsController.clear();
    exchangeForGiftsController.clear();

    shortNameController.clear();
    fullNameController.clear();
    latinShortNameController.clear();
    latinFullNameController.clear();
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
    isLoading = false;
    update();
  }

  Future<void> addNewPattern() async {
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
        billTypeLabel: selectedBillType.value,
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
