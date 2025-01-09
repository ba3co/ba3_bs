import 'package:ba3_bs/features/tax/data/models/tax_model.dart';
import 'package:get/get.dart';


abstract class ITexSelectionHandler {
  Rx<VatEnums> get selectedTax;

  void onSelectedTaxChanged(VatEnums? newTax);
}
