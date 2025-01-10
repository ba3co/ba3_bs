import 'package:ba3_bs/core/helper/extensions/bisc/double_nullable_to_string.dart';
import 'package:ba3_bs/core/helper/extensions/bisc/int_nullable_to_string.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:ba3_bs/features/tax/data/models/tax_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../../../core/interfaces/i_tex_selection_handler.dart';

class MaterialFromHandler with AppValidator implements ITexSelectionHandler {
  MaterialController get materialController => read<MaterialController>();

  final formKey = GlobalKey<FormState>();

  TextEditingController nameController = TextEditingController();
  TextEditingController latinNameController = TextEditingController();
  TextEditingController codeController = TextEditingController();
  TextEditingController customerPriceController = TextEditingController();
  TextEditingController wholePriceController = TextEditingController();
  TextEditingController retailPriceController = TextEditingController();
  TextEditingController costPriceController = TextEditingController();
  TextEditingController minPriceController = TextEditingController();
  TextEditingController barcodeController = TextEditingController();

  VatEnums _taxModel = VatEnums.withVat;
  late MaterialModel? parentModel;

  void init(MaterialModel? material) {
    if (material != null) {
      materialController.selectedMaterial = material;
      nameController.text = materialController.selectedMaterial!.matName!;
      codeController.text = materialController.selectedMaterial!.matCode!.toFixedString();
      customerPriceController.text = materialController.selectedMaterial!.endUserPrice!;
      wholePriceController.text = materialController.selectedMaterial!.wholesalePrice!;
      retailPriceController.text = materialController.selectedMaterial!.retailPrice!;
      costPriceController.text = materialController.selectedMaterial!.matCurrencyVal!.toFixedString();
      minPriceController.text = materialController.selectedMaterial!.matLastPriceCurVal!.toFixedString();
      barcodeController.text = materialController.selectedMaterial!.matBarCode!;
      latinNameController.text = materialController.selectedMaterial!.matCompositionLatinName!;
    } else {
      materialController.selectedMaterial = null;
      parentModel = null;

      clear();
    }
  }

  void clear() {
    nameController.clear();
    codeController.clear();
    customerPriceController.clear();
    wholePriceController.clear();
    retailPriceController.clear();
    costPriceController.clear();
    minPriceController.clear();
    barcodeController.clear();
    latinNameController.clear();
    parentController.clear();
  }

  bool validate() => formKey.currentState?.validate() ?? false;

  void dispose() {
    nameController.dispose();
    codeController.dispose();
    customerPriceController.dispose();
    wholePriceController.dispose();
    retailPriceController.dispose();
    costPriceController.dispose();
    minPriceController.dispose();
    barcodeController.dispose();
    latinNameController.dispose();
    parentController.dispose();
  }

  String? defaultValidator(String? value, String fieldName) => isFieldValid(value, fieldName);

  @override
  void onSelectedTaxChanged(VatEnums? newTax) {
    _taxModel = newTax!;
    materialController.update();
  }

  @override
  Rx<VatEnums> get selectedTax => _taxModel.obs;

  TextEditingController parentController = TextEditingController();
}
