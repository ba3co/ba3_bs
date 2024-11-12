import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/utils.dart';
import '../../../materials/data/models/material_model.dart';
import '../../controllers/invoice_pluto_controller.dart';

class InvoicePlutoUtils {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  PlutoGridStateManager get additionsDiscountsStateManager => invoicePlutoController.additionsDiscountsStateManager;

  double getPrice({required MaterialModel materialModel, required PriceType type}) {
    switch (type) {
      case PriceType.consumer:
        return double.tryParse(materialModel.endUserPrice ?? '') ?? 0;
      case PriceType.bulk:
        return double.tryParse(materialModel.wholesalePrice ?? '') ?? 0;
      case PriceType.retail:
        return double.tryParse(materialModel.retailPrice ?? '') ?? 0;
      default:
        throw ArgumentError('Unknown price method: $type');
    }
  }

  double parseExpression(String expression) {
    return Parser().parse(expression).evaluate(EvaluationType.REAL, ContextModel());
  }

  bool isValidItemQuantity(PlutoRow row, String cellKey) {
    final String cellValue = row.cells[cellKey]?.value.toString() ?? '';

    int invRecQuantity = int.tryParse(Utils.replaceArabicNumbersWithEnglish(cellValue)) ?? 0;

    return invRecQuantity > 0;
  }

  double getCellValueInDouble(Map<String, PlutoCell> cells, String cellKey) {
    final String cellValue = cells[cellKey]?.value.toString() ?? '';

    return double.tryParse(Utils.replaceArabicNumbersWithEnglish(cellValue)) ?? 0;
  }

  PlutoRow get ratioRow => additionsDiscountsStateManager.rows.firstWhere(
        (row) => row.cells[AppConstants.id]?.value == AppConstants.ratio,
      );

  PlutoRow get valueRow => additionsDiscountsStateManager.rows.firstWhere(
        (row) => row.cells[AppConstants.id]?.value == AppConstants.value,
      );
}
