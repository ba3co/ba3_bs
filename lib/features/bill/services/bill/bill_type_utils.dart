import '../../../../core/helper/enums/enums.dart';
import '../../data/models/bill_model.dart';

class BillTypeUtils {
  /// Retrieves the BillType from the BillModel.
  static BillType getBillType(BillModel billModel) => BillType.byLabel(billModel.billTypeModel.billTypeLabel!);

  /// Checks if the BillType is related to a **purchase transaction**.
  static bool isPurchaseRelated(BillModel billModel) {
    final BillType billType = getBillType(billModel);

    return {
      BillType.purchase,
      BillType.salesReturn,
      BillType.adjustmentEntry,
      BillType.firstPeriodInventory,
      BillType.transferIn,
    }.contains(billType);
  }

  /// Checks if the BillType is related to a **sales transaction**.
  static bool isSellRelated(BillModel billModel) {
    final BillType billType = getBillType(billModel);

    return {
      BillType.sales,
      BillType.purchaseReturn,
      BillType.outputAdjustment,
      BillType.transferOut,
    }.contains(billType);
  }
}
