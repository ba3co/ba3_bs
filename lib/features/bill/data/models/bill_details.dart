import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class BillDetails with EquatableMixin {
  final String? billGuid;
  final int? billPayType;
  final int? billNumber;

  /// The number of the previous bill
  final int? previous;

  /// The number of the next bill
  final int? next;
  final DateTime? billDate;
  final String? billNote;
  final String? billSellerId;
  final String? billCustomerId;
  final double? billTotal;
  final double? billVatTotal;
  final double? billBeforeVatTotal;
  final double? billGiftsTotal;
  final double? billDiscountsTotal;
  final double? billAdditionsTotal;
  final double? billFirstPay;

  BillDetails({
    this.billGuid,
    this.billPayType,
    this.billNumber,
    this.previous,
    this.next,
    this.billDate,
    this.billNote,
    this.billCustomerId,
    this.billTotal,
    this.billVatTotal,
    this.billBeforeVatTotal,
    this.billSellerId,
    this.billGiftsTotal,
    this.billDiscountsTotal,
    this.billAdditionsTotal,
    this.billFirstPay,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) => BillDetails(
        billGuid: json['billGuid'],
        billPayType: json['billPayType'],
        billNumber: json['billNumber'],
        previous: json['previous'],
        next: json['next'],
        billDate: (json['billDate'] as Timestamp).toDate(),
        billNote: json['billNote'],
        billCustomerId: json['billCustomerId'],
        billSellerId: json['billSellerId'],
        billTotal: json['billTotal'],
        billVatTotal: json['billVatTotal'],
        billBeforeVatTotal: json['billWithoutVatTotal'],
        billGiftsTotal: json['billGiftsTotal'],
        billDiscountsTotal: json['billDiscountsTotal'],
        billAdditionsTotal: json['billAdditionsTotal'],
        billFirstPay: json['billFirstPay'],
      );

  factory BillDetails.fromBillData({
    BillDetails? existingDetails,
    String? billNote,
    required String billCustomerId,
    required String billSellerId,
    required int billPayType,
    required DateTime billDate,
    required double billTotal,
    required double billVatTotal,
    required double billWithoutVatTotal,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required double billFirstPay,
  }) =>
      BillDetails(
        billGuid: existingDetails?.billGuid,
        billNumber: existingDetails?.billNumber,
        previous: existingDetails?.previous,
        next: existingDetails?.next,
        billNote: billNote,
        billFirstPay: billFirstPay,
        billCustomerId: billCustomerId,
        billSellerId: billSellerId,
        billPayType: billPayType,
        billDate: billDate,
        billTotal: billTotal,
        billVatTotal: billVatTotal,
        billBeforeVatTotal: billWithoutVatTotal,
        billGiftsTotal: billGiftsTotal,
        billDiscountsTotal: billDiscountsTotal,
        billAdditionsTotal: billAdditionsTotal,
      );

  Map<String, dynamic> toJson() => {
        'billGuid': billGuid,
        'billPayType': billPayType,
        'billNumber': billNumber,
        'previous': previous,
        'next': next,
        'billDate': Timestamp.fromDate(billDate!),
        'billNote': billNote,
        'billCustomerId': billCustomerId,
        'billTotal': billTotal,
        'billWithoutVatTotal': billBeforeVatTotal,
        'billVatTotal': billVatTotal,
        'billSellerId': billSellerId,
        'billGiftsTotal': billGiftsTotal,
        'billDiscountsTotal': billDiscountsTotal,
        'billAdditionsTotal': billAdditionsTotal,
        'billFirstPay': billFirstPay,
      };

  BillDetails copyWith({
    final String? billGuid,
    final int? billPayType,
    final int? billNumber,
    final int? previous,
    final int? next,
    final DateTime? billDate,
    final String? billNote,
    final String? billCustomerId,
    final String? billSellerId,
    final double? billTotal,
    final double? billVatTotal,
    final double? billBeforeVatTotal,
    final double? billGiftsTotal,
    final double? billDiscountsTotal,
    final double? billAdditionsTotal,
    final double? billFirstPay,
  }) =>
      BillDetails(
        billGuid: billGuid ?? this.billGuid,
        billPayType: billPayType ?? this.billPayType,
        billNumber: billNumber ?? this.billNumber,
        previous: previous ?? this.previous,
        next: next ?? this.next,
        billDate: billDate ?? this.billDate,
        billNote: billNote ?? this.billNote,
        billTotal: billTotal ?? this.billTotal,
        billVatTotal: billVatTotal ?? this.billVatTotal,
        billBeforeVatTotal: billBeforeVatTotal ?? this.billBeforeVatTotal,
        billCustomerId: billCustomerId ?? this.billCustomerId,
        billSellerId: billSellerId ?? this.billSellerId,
        billDiscountsTotal: billDiscountsTotal ?? this.billDiscountsTotal,
        billGiftsTotal: billGiftsTotal ?? this.billGiftsTotal,
        billAdditionsTotal: billAdditionsTotal ?? this.billAdditionsTotal,
        billFirstPay: billFirstPay ?? this.billFirstPay,
      );

  @override
  List<Object?> get props => [
        billGuid,
        billPayType,
        billNumber,
        previous,
        next,
        billDate,
        billNote,
        billCustomerId,
        billSellerId,
        billTotal,
        billVatTotal,
        billBeforeVatTotal,
        billGiftsTotal,
        billDiscountsTotal,
        billAdditionsTotal,
      ];
}
