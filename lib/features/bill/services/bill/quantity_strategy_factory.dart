import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/bill/services/bill/quantity_strategy.dart';

import 'bill_type_utils.dart';

class QuantityStrategyFactory {
  static QuantityStrategy getStrategy(BillModel billModel) {
    final bool isPurchaseRelated = BillTypeUtils.isPurchaseRelated(billModel);

    if (isPurchaseRelated) {
      return AddQuantityStrategy();
    } else {
      return SubtractQuantityStrategy();
    }
  }
}
