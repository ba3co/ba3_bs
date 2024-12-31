import '../enums/enums.dart';

extension BillPatternTypeExtension on BillPatternType {

  /// This function checks the permission status based on the [BillPatternType].
  bool _checkPermissionStatus() {
    switch (this) {
    case BillPatternType.purchase:
    return true;
    case BillPatternType.sales:
    return true;


    case BillPatternType.add:
      case BillPatternType.remove:
    return false;

    case BillPatternType.openingStock:
    return false;

    case BillPatternType.buyReturn:
    case BillPatternType.salesReturn:
    return true;

    }
  }

  /// Returns whether the current [BillPatternType] has material account.
  bool get hasMaterialAccount => _checkPermissionStatus();

  /// Returns whether the current [BillPatternType] has cashes account.
  bool get hasCashesAccount => _checkPermissionStatus();

  /// Returns whether the current [BillPatternType] has additions account.
  bool get hasAdditionsAccount => _checkPermissionStatus();

  /// Returns whether the current [BillPatternType] has discounts account.
  bool get hasDiscountsAccount => _checkPermissionStatus();

  /// Returns whether the current [BillPatternType] has gifts account.
  bool get hasGiftsAccount => _checkPermissionStatus();
}
