import 'package:math_expressions/math_expressions.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/constants/app_constants.dart';
import '../../materials/data/models/material_model.dart';

class InvoiceUtils {
  double getPrice({required MaterialModel materialModel, required String type}) {
    double price = 0;

    switch (type) {
      case AppConstants.invoiceChoosePriceMethodeCustomerPrice:
        price = double.parse(materialModel.endUserPrice ?? "0");
        break;
      case AppConstants.invoiceChoosePriceMethodeWholePrice:
        price = double.parse(materialModel.wholesalePrice ?? "0");
        break;
      case AppConstants.invoiceChoosePriceMethodeRetailPrice:
        price = double.parse(materialModel.retailPrice ?? "0");
        break;

      default:
        throw ArgumentError("Unknown price method: $type");
    }

    return price;
  }

  double parseExpression(String expression) {
    return Parser().parse(expression).evaluate(EvaluationType.REAL, ContextModel());
  }

  bool validateInvoiceRow(PlutoRow row, String cellKey) {
    final cellValue = row.cells[cellKey]?.value ?? 0;
    return cellValue > 0;
  }
}
