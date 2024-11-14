class BillDetails {
  final String? billGuid;
  final int? billPayType;
  final int? billNumber;
  final String? billDate;
  final String? note;
  final String? billSellerId;
  final String? billCustomerId;
  final double? billTotal;
  final double? billVatTotal;
  final double? billWithoutVatTotal;
  final double? billGiftsTotal;
  final double? billDiscountsTotal;
  final double? billAdditionsTotal;

  BillDetails({
    this.billGuid,
    this.billPayType,
    this.billNumber,
    this.billDate,
    this.note,
    this.billCustomerId,
    this.billTotal,
    this.billVatTotal,
    this.billWithoutVatTotal,
    this.billSellerId,
    this.billGiftsTotal,
    this.billDiscountsTotal,
    this.billAdditionsTotal,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) => BillDetails(
        billGuid: json['billGuid'],
        billPayType: json['billPayType'],
        billNumber: json['billNumber'],
        billDate: json['billDate'],
        note: json['note'],
        billCustomerId: json['billCustomerId'],
        billSellerId: json['billSellerId'],
        billTotal: json['billTotal'],
        billVatTotal: json['billVatTotal'],
        billWithoutVatTotal: json['billWithoutVatTotal'],
        billGiftsTotal: json['billGiftsTotal'],
        billDiscountsTotal: json['billDiscountsTotal'],
        billAdditionsTotal: json['billAdditionsTotal'],
      );

  factory BillDetails.fromInvoiceData({
    BillDetails? existingDetails,
    String? note,
    required String billCustomerId,
    required String billSellerId,
    required int billPayType,
    required String billDate,
    required double billTotal,
    required double billVatTotal,
    required double billWithoutVatTotal,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
  }) =>
      BillDetails(
        billGuid: existingDetails?.billGuid,
        billNumber: existingDetails?.billNumber,
        note: note,
        billCustomerId: billCustomerId,
        billSellerId: billSellerId,
        billPayType: billPayType,
        billDate: billDate,
        billTotal: billTotal,
        billVatTotal: billVatTotal,
        billWithoutVatTotal: billWithoutVatTotal,
        billGiftsTotal: billGiftsTotal,
        billDiscountsTotal: billDiscountsTotal,
        billAdditionsTotal: billAdditionsTotal,
      );

  Map<String, dynamic> toJson() => {
        'billGuid': billGuid,
        'billPayType': billPayType,
        'billNumber': billNumber,
        'billDate': billDate,
        'note': note,
        'billCustomerId': billCustomerId,
        'billTotal': billTotal,
        'billWithoutVatTotal': billWithoutVatTotal,
        'billVatTotal': billVatTotal,
        'billSellerId': billSellerId,
        'billGiftsTotal': billGiftsTotal,
        'billDiscountsTotal': billDiscountsTotal,
        'billAdditionsTotal': billAdditionsTotal,
      };

  BillDetails copyWith({
    final String? billGuid,
    final int? billPayType,
    final int? billNumber,
    final String? billDate,
    final String? note,
    final String? billCustomerId,
    final String? billSellerId,
    final double? billTotal,
    final double? billVatTotal,
    final double? billWithoutVatTotal,
    final double? billGiftsTotal,
    final double? billDiscountsTotal,
    final double? billAdditionsTotal,
  }) =>
      BillDetails(
        billGuid: billGuid ?? this.billGuid,
        billPayType: billPayType ?? this.billPayType,
        billNumber: billNumber ?? this.billNumber,
        billDate: billDate ?? this.billDate,
        note: note ?? this.note,
        billTotal: billTotal ?? this.billTotal,
        billVatTotal: billVatTotal ?? this.billVatTotal,
        billWithoutVatTotal: billWithoutVatTotal ?? this.billWithoutVatTotal,
        billCustomerId: billCustomerId ?? this.billCustomerId,
        billSellerId: billSellerId ?? this.billSellerId,
        billDiscountsTotal: billDiscountsTotal ?? this.billDiscountsTotal,
        billGiftsTotal: billGiftsTotal ?? this.billGiftsTotal,
        billAdditionsTotal: billAdditionsTotal ?? this.billAdditionsTotal,
      );
}
