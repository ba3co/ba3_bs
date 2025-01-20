import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';

List<EntryBondItemModel> items = [
  EntryBondItemModel(
    amount: 100,
    bondItemType: BondItemType.debtor,
    account: AccountEntityN(id: '1', name: '#1'),
  ),
  EntryBondItemModel(
    amount: 100,
    bondItemType: BondItemType.creditor,
    account: AccountEntityN(id: '2', name: '#2'),
  ),
  EntryBondItemModel(
    amount: 200,
    bondItemType: BondItemType.creditor,
    account: AccountEntityN(id: '1', name: '#1'),
  ),
  EntryBondItemModel(
    amount: 200,
    bondItemType: BondItemType.debtor,
    account: AccountEntityN(id: '4', name: '#4'),
  ),
];

void main() async {
  final groupBy = items.groupBy((item) => item.account.id);
  print('groupBy $groupBy');
}

class AccountEntityN {
  final String id;
  final String name;

  const AccountEntityN({
    required this.id,
    required this.name,
  });

  factory AccountEntityN.fromJson(Map<String, dynamic> json) {
    return AccountEntityN(
      id: json['AccPtr'],
      name: json['AccName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'AccPtr': id,
      'AccName': name,
    };
  }

  @override
  String toString() {
    return 'AccountEntity(id: $id, name: $name)';
  }
}

/// Represents a bond entry with associated details and items.
class EntryBondModel {
  /// Contains an identifier and a list of bond items.
  final EntryBondItems? items;

  /// Refers to the origin entity of the bond entry (e.g., billTypeId for invoices).
  final EntryBondOrigin? origin;

  EntryBondModel({this.items, this.origin});

  /// Creates an instance from a JSON object.
  factory EntryBondModel.fromJson(Map<String, dynamic> json) {
    return EntryBondModel(
      items: json['items'] != null ? EntryBondItems.fromJson(json['items']) : null,
      origin: EntryBondOrigin.fromJson(json['origin']),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'items': items?.toJson(),
      'origin': origin?.toJson(),
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondModel copyWith({
    EntryBondItems? items,
    EntryBondOrigin? origin,
  }) {
    return EntryBondModel(
      items: items ?? this.items,
      origin: origin ?? this.origin,
    );
  }
}

/// Represents a collection of bond items with an identifier.
class EntryBondItems {
  /// Unique identifier for the bond items.
  final String id;
  final String? docId;

  /// List of bond items.
  final List<EntryBondItemModel> itemList;

  EntryBondItems({required this.id, required this.itemList, this.docId});

  /// Creates an instance from a JSON object.
  factory EntryBondItems.fromJson(Map<String, dynamic> json) {
    return EntryBondItems(
      id: json['id'] ?? json['docId'],
      docId: json['docId'] as String?,
      itemList: (json['items'] as List<dynamic>)
          .map((item) => EntryBondItemModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      if (docId != null) 'docId': docId,
      if (docId != null) 'id': id,
      if (docId == null) 'docId': id,
      'items': itemList.map((item) => item.toJson()).toList(),
    };
  }

  EntryBondItems copyWith({
    final String? id,
    final String? docId,
    final List<EntryBondItemModel>? itemList,
  }) {
    return EntryBondItems(
      id: id ?? this.id,
      docId: docId ?? this.docId,
      itemList: itemList ?? this.itemList,
    );
  }
}

enum BondItemType {
  creditor('الدائن'),
  debtor('مدين');

  final String label;

  const BondItemType(this.label);

  // Factory constructor with error handling for unmatched labels
  factory BondItemType.byLabel(String label) {
    return BondItemType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching BondItemType for label: $label'),
    );
  }
}

enum EntryBondType {
  bond('bond'),
  bill('bill'),
  cheque('cheque');

  final String label;

  const EntryBondType(this.label);

  // Factory constructor with error handling for unmatched labels
  factory EntryBondType.byLabel(String label) {
    return EntryBondType.values.firstWhere(
      (type) => type.label == label,
      orElse: () => throw ArgumentError('No matching EntryBondType for label: $label'),
    );
  }
}

/// Represents a single bond item within a bond entry.
class EntryBondItemModel {
  /// Type of the bond item, defined by an enum.
  final BondItemType? bondItemType;

  /// The monetary amount associated with this bond item.
  final double? amount;

  /// The account related to this bond item.
  final AccountEntityN account;

  /// Additional notes or comments for this bond item.
  final String? note;

  /// Refers to the bond entry ID that this item belongs to.
  final String? originId;
  final String? docId;

  final String? date;

  EntryBondItemModel({
    this.bondItemType,
    this.amount,
    this.note,
    this.originId,
    this.date,
    this.docId,
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
      docId: json['docId'] as String?,
      account: AccountEntityN.fromJson(json['account']),
    );
  }

  /// Converts the instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'bondItemType': bondItemType?.label,
      'amount': amount,
      'note': note,
      'originId': originId,
      'date': date,
      'docId': docId,
      'account': account.toJson(),
    };
  }

  /// Creates a new instance with modified fields.
  EntryBondItemModel copyWith({
    final BondItemType? bondItemType,
    final double? amount,
    final String? note,
    final String? originId,
    final String? docId,
    final String? date,
    final AccountEntityN? account,
  }) {
    return EntryBondItemModel(
      bondItemType: bondItemType ?? this.bondItemType,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      originId: originId ?? this.originId,
      date: date ?? this.date,
      docId: docId ?? this.docId,
      account: account ?? this.account,
    );
  }

  @override
  String toString() {
    return 'EntryBondItemModel(amount: $amount, bondItemType: $bondItemType, Account id: ${account.id}, Account name:'
        ' ${account.name})';
  }
}

class EntryBondOrigin {
  /// Unique identifier for the bond entry, which is the same as the origin ID (e.g., billId).
  final String? originId;
  final String? docId;

  /// Refers to the origin entity type id of the bond entry (e.g., billTypeId for bills).
  final String? originTypeId;

  /// Refers to the type of the bond entry (bond, bill, cheque).
  final EntryBondType? originType;

  EntryBondOrigin({
    this.originId,
    this.docId,
    this.originTypeId,
    this.originType,
  });

  factory EntryBondOrigin.fromJson(Map<String, dynamic> json) {
    return EntryBondOrigin(
      originId: json['originId'] as String?,
      docId: json['docId'] as String?,
      originTypeId: json['originTypeId'] as String?,
      originType: EntryBondType.byLabel(json['originType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'originId': originId,
      'docId': docId,
      'originTypeId': originTypeId,
      'originType': originType?.label,
    };
  }

  EntryBondOrigin copyWith({
    String? originId,
    String? originTypeId,
    String? docId,
    EntryBondType? originType,
  }) {
    return EntryBondOrigin(
      originId: originId ?? this.originId,
      originTypeId: originTypeId ?? this.originTypeId,
      originType: originType ?? this.originType,
      docId: docId ?? this.docId,
    );
  }
}
