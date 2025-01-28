import 'package:ba3_bs/features/bill/services/bill/quantity_strategy.dart';

import '../../../../core/helper/enums/enums.dart';

class QuantityStrategyFactory {
  static QuantityStrategy getStrategy(BillType billType) {
    switch (billType) {
      case BillType.purchase:
      case BillType.salesReturn:
      case BillType.adjustmentEntry:
      case BillType.firstPeriodInventory:
      case BillType.transferIn:
        return AddQuantityStrategy();

      case BillType.sales:
      case BillType.purchaseReturn:
      case BillType.outputAdjustment:
      case BillType.transferOut:
        return SubtractQuantityStrategy();
    }
  }
}
