import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/helper/validators/app_validator.dart';
import 'package:ba3_bs/core/interfaces/i_store_selection_handler.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/get_rx.dart';
import '../../controllers/bonds/all_bond_controller.dart';
import '../../data/models/bond_type.dart';


/// Form handler for BondType creation/editing.
class BondTypeFormHandler with AppValidator implements IStoreSelectionHandler {
  /// Access the bond type controller
  AllBondsController get bondTypeController => read<AllBondsController>();

  final formKey = GlobalKey<FormState>();

  /// Form fields mapped to BondTypeModel attributes
  final TextEditingController labelController = TextEditingController();
  final TextEditingController valueController = TextEditingController();
  final TextEditingController typeGuideController = TextEditingController();
  final TextEditingController fromController = TextEditingController();
  final TextEditingController toController = TextEditingController();
  final TextEditingController taxTypeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();

  /// Selected BondType (enum)
  Rx<BondType?> selectedBondType = Rx<BondType?>(null);

  /// Selected model being edited or viewed
  BondTypeModel? selectedBondTypeModel;

  @override
  Rx<StoreAccount> selectedStore = StoreAccount.main.obs;

  /// Initialize the form with an existing BondTypeModel
  void init(BondTypeModel? bondType) {
    if (bondType != null) {
      selectedBondTypeModel = bondType;
      selectedBondType.value = bondType.type;

      labelController.text = bondType.label;
      valueController.text = bondType.value;
      typeGuideController.text = bondType.typeGuide;
      fromController.text = bondType.from.toString();
      toController.text = bondType.to.toString();
      taxTypeController.text = bondType.taxType.toString();
      colorController.text = bondType.color;
    } else {
      clear();
      selectedBondTypeModel = null;
      selectedBondType.value = null;
    }
  }

  /// Creates a BondTypeModel from the form
  BondTypeModel toModel() {
    return BondTypeModel(
      label: labelController.text,
      value: valueController.text,
      typeGuide: typeGuideController.text,
      from: int.tryParse(fromController.text) ?? 0,
      to: int.tryParse(toController.text) ?? 0,
      taxType: int.tryParse(taxTypeController.text) ?? 0,
      color: colorController.text,
      type: selectedBondType.value ??
          (throw Exception('BondType must be selected')),
    );
  }

  /// Clears all form fields
  void clear() {
    labelController.clear();
    valueController.clear();
    typeGuideController.clear();
    fromController.clear();
    toController.clear();
    taxTypeController.clear();
    colorController.clear();
  }

  /// Optional: Dispose all controllers when done
  void dispose() {
    labelController.dispose();
    valueController.dispose();
    typeGuideController.dispose();
    fromController.dispose();
    toController.dispose();
    taxTypeController.dispose();
    colorController.dispose();
  }

  /// Form validation
  bool validate() => formKey.currentState?.validate() ?? false;

  /// Handle color change from color picker or dropdown
  void onMainColorChanged(int? newColorValue) {
    if (newColorValue != null) {
      debugPrint(newColorValue.toString());
      colorController.text = newColorValue.toString();
      bondTypeController.update();
    }
  }

  /// Handle enum selection change
  void onTypeChanged(BondType? newType) {
    if (newType != null) {
      selectedBondType.value = newType;
      taxTypeController.text=selectedBondType.value!.taxType.toString();
      bondTypeController.update();
    }
  }



  @override
  void onSelectedStoreChanged(StoreAccount? newStore) {
    if (newStore != null) selectedStore.value = newStore;
  }



  /// Helper for validation (using AppValidator mixin)
  String? validator(String? value, String fieldName) =>
      isFieldValid(value, fieldName);
}
