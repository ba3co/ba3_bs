class InvoiceModel {
  final String? id;
  final String? invName;
  final String? invTotal;
  final String? invSubTotal;
  final String? invPrimaryAccount;
  final String? invSecondaryAccount;
  final String? invStorehouse;
  final String? invComment;
  final String? invType;
  final List<String>? invRecords;

  InvoiceModel({
    this.id,
    this.invName,
    this.invTotal,
    this.invSubTotal,
    this.invPrimaryAccount,
    this.invSecondaryAccount,
    this.invStorehouse,
    this.invComment,
    this.invType,
    this.invRecords,
  });

  factory InvoiceModel.fromJson(Map json) => InvoiceModel(
        id: json['invId'],
        invName: json['invName'],
        invTotal: json['invTotal'],
        invSubTotal: json['invSubTotal'],
        invPrimaryAccount: json['invPrimaryAccount'],
        invSecondaryAccount: json['invSecondaryAccount'],
        invStorehouse: json['invStorehouse'],
        invComment: json['invComment'],
        invType: json['invType'],
        invRecords: json['invRecords'],
      );

  Map<String, dynamic> toJson() => {
        'invId': id,
        'invName': invName,
        'invTotal': invTotal,
        'invSubTotal': invSubTotal,
        'invPrimaryAccount': invPrimaryAccount,
        'invSecondaryAccount': invSecondaryAccount,
        'invStorehouse': invStorehouse,
        'invComment': invComment,
        'invType': invType,
        'invRecords': invRecords,
      };

  InvoiceModel copyWith({
    String? id,
    String? invName,
    String? invTotal,
    String? invSubTotal,
    String? invPrimaryAccount,
    String? invSecondaryAccount,
    String? invStorehouse,
    String? invComment,
    String? invType,
    List<String>? invRecords,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      invName: invName ?? this.invName,
      invTotal: invTotal ?? this.invTotal,
      invSubTotal: invSubTotal ?? this.invSubTotal,
      invPrimaryAccount: invPrimaryAccount ?? this.invPrimaryAccount,
      invSecondaryAccount: invSecondaryAccount ?? this.invSecondaryAccount,
      invStorehouse: invStorehouse ?? this.invStorehouse,
      invComment: invComment ?? this.invComment,
      invType: invType ?? this.invType,
      invRecords: invRecords ?? this.invRecords,
    );
  }
}
