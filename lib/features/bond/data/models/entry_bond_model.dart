import '../../../../core/helper/enums/enums.dart';

/// Represents a bond entry with associated details and items.
class EntryBondModel {
  /// List of bond items associated with this bond entry.
  final List<EntryBondItemModel>? bonds;

  /// Refers to the origin entity of the bond entry (e.g., billTypeId for invoices).
  final String? originGuid;

  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? id;

  EntryBondModel({
    this.bonds,
    this.originGuid,
    this.id,
  });
}

/// Represents a single bond item within a bond entry.
class EntryBondItemModel {
  /// Type of the bond item, defined by an enum.
  final BondItemType? bondItemType;

  /// The monetary amount associated with this bond item.
  final double? amount;

  /// The account related to this bond item.
  final String? account;

  /// Additional notes or comments for this bond item.
  final String? note;

  /// Refers to the bond entry ID that this item belongs to.
  final String? originGuid;

  EntryBondItemModel({
    this.bondItemType,
    this.amount,
    this.account,
    this.note,
    this.originGuid,
  });
}
