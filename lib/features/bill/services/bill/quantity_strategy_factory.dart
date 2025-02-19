import 'package:ba3_bs/core/helper/extensions/bill/bill_model_extensions.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/bill/services/bill/quantity_strategy.dart';

class QuantityStrategyFactory {
  static QuantityStrategy getStrategy(BillModel billModel) {
    final bool isPurchaseRelated = billModel.isPurchaseRelated;

    if (isPurchaseRelated) {
      return AddQuantityStrategy();
    } else {
      return SubtractQuantityStrategy();
    }
  }
}
