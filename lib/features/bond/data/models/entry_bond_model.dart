import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';
import '../../../pluto/data/models/pluto_adaptable.dart';

/// Represents a bond entry with associated details and items.
class EntryBondModel {
  /// List of bond items associated with this bond entry.
  final List<EntryBondItemModel>? items;

  /// Refers to the origin entity of the bond entry (e.g., billTypeId for invoices).
  final EntryBondOrigin? origin;

  EntryBondModel({this.items, this.origin});

  /// Creates an instance from a JSON object.
  factory EntryBondModel.fromJson(Map<String, dynamic> json) {
    return EntryBondModel(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => EntryBondItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      origin: EntryBondOrigin.fromJson(json['origin']),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'items': items?.map((item) => item.toJson()).toList(),
      'origin': origin?.toJson(),
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondModel copyWith({
    List<EntryBondItemModel>? items,
    EntryBondOrigin? origin,
  }) {
    return EntryBondModel(
      items: items ?? this.items,
      origin: origin ?? this.origin,
    );
  }
}

/// Represents a single bond item within a bond entry.
class EntryBondItemModel implements PlutoAdaptable {
  /// Type of the bond item, defined by an enum.
  final BondItemType? bondItemType;

  /// The monetary amount associated with this bond item.
  final double? amount;

  /// The account related to this bond item.
  final AccountEntity account;

  /// Additional notes or comments for this bond item.
  final String? note;

  /// Refers to the bond entry ID that this item belongs to.
  final String? originId;

  final String? date;

  EntryBondItemModel({
    this.bondItemType,
    this.amount,
    this.note,
    this.originId,
    this.date,
    required this.account,
  });

  /// Creates an instance from a JSON object.
  factory EntryBondItemModel.fromJson(Map<String, dynamic> json) {
    return EntryBondItemModel(
      bondItemType: BondItemType.byLabel(json['bondItemType']),
      amount: (json['amount'] as num?)?.toDouble(),
      note: json['note'] as String?,
      originId: json['docId'] as String?,
      date: json['date'] as String?,
      account: AccountEntity.fromJson(json['account']),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'bondItemType': bondItemType?.label,
      'amount': amount,
      'note': note,
      'docId': originId,
      'date': date,
      'account': account.toJson(),
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondItemModel copyWith({
    final BondItemType? bondItemType,
    final double? amount,
    final String? note,
    final String? originId,
    final String? date,
    final AccountEntity? account,
  }) {
    return EntryBondItemModel(
      bondItemType: bondItemType ?? this.bondItemType,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      originId: originId ?? this.originId,
      date: date ?? this.date,
      account: account ?? this.account,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([void _]) {
    return {
      PlutoColumn(hide: true, title: 'originId', field: 'originId', type: PlutoColumnType.text()): originId ?? '',
      createAutoIdColumn(): '',
      PlutoColumn(
          title: 'مدين',
          field: 'مدين',
          type: PlutoColumnType.currency(
            format: '#,##0.00 AED',
            locale: 'en_AE',
            symbol: 'AED',
          )): bondItemType == BondItemType.debtor ? amount : 0,
      PlutoColumn(
          title: 'دائن',
          field: 'دائن',
          type: PlutoColumnType.currency(
            format: '#,##0.00 AED',
            locale: 'en_AE',
            symbol: 'AED',
          )): bondItemType == BondItemType.creditor ? amount : 0,
      PlutoColumn(title: 'الحساب', field: 'الحساب', type: PlutoColumnType.text()): account.name ?? '',
      PlutoColumn(title: 'التاريخ', field: 'التاريخ', type: PlutoColumnType.date()): date,
      PlutoColumn(title: 'البيان', field: 'البيان', type: PlutoColumnType.text()): note,
    };
  }
}

class EntryBondOrigin {
  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? originId;

  /// Refers to the origin entity type id of the bond entry (e.g., billTypeId for bills).
  final String? originTypeId;

  /// Refers to the type of the bond entry (bond, bill, cheque).
  final EntryBondType? originType;

  EntryBondOrigin({
    this.originId,
    this.originTypeId,
    this.originType,
  });

  factory EntryBondOrigin.fromJson(Map<String, dynamic> json) {
    return EntryBondOrigin(
      originId: json['originId'] as String?,
      originTypeId: json['originTypeId'] as String?,
      originType: EntryBondType.byLabel(json['originType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originId': originId,
      'originTypeId': originTypeId,
      'originType': originType?.label,
    };
  }

  EntryBondOrigin copyWith({
    String? originId,
    String? originTypeId,
    EntryBondType? originType,
  }) {
    return EntryBondOrigin(
      originId: originId ?? this.originId,
      originTypeId: originTypeId ?? this.originTypeId,
      originType: originType ?? this.originType,
    );
  }
}
