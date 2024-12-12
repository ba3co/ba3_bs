import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/bond/data/models/pay_item_model.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';

class BondModel extends PlutoAdaptable {
  final BondType? payTypeGuid;
  final int? payNumber;
  final String? payGuid;
  final String? payBranchGuid;
  final String? payDate;
  final String? entryPostDate;
  final String? payNote;
  final String? payCurrencyGuid;
  final double? payCurVal;
  final String? payAccountGuid;
  final int? paySecurity;
  final int? paySkip;
  final int? erParentType;
  final List<PayItem> payItems;
  final String? e;

  BondModel({
    this.payTypeGuid,
    this.payNumber,
    this.payGuid,
    this.payBranchGuid,
    this.payDate,
    this.entryPostDate,
    this.payNote,
    this.payCurrencyGuid,
    this.payCurVal,
    this.payAccountGuid,
    this.paySecurity,
    this.paySkip,
    this.erParentType,
    required this.payItems,
    this.e,
  });

  factory BondModel.fromJson(Map<String, dynamic> json) {
    return BondModel(
      payTypeGuid: json['PayTypeGuid'],
      payNumber: json['PayNumber'],
      payGuid: json['PayGuid'],
      payBranchGuid: json['PayBranchGuid'],
      payDate: json['PayDate'],
      entryPostDate: json['EntryPostDate'],
      payNote: json['PayNote'],
      payCurrencyGuid: json['PayCurrencyGuid'],
      payCurVal: json['PayCurVal'].toDouble(),
      payAccountGuid: json['PayAccountGuid'],
      paySecurity: json['PaySecurity'],
      paySkip: json['PaySkip'],
      erParentType: json['ErParentType'],
      payItems: (json['PayItems']['N'] as List).map((item) => PayItem.fromJson(item)).toList(),
      e: json['E'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'PayTypeGuid': payTypeGuid,
      'PayNumber': payNumber,
      'PayGuid': payGuid,
      'PayBranchGuid': payBranchGuid,
      'PayDate': payDate,
      'EntryPostDate': entryPostDate,
      'PayNote': payNote,
      'PayCurrencyGuid': payCurrencyGuid,
      'PayCurVal': payCurVal,
      'PayAccountGuid': payAccountGuid,
      'PaySecurity': paySecurity,
      'PaySkip': paySkip,
      'ErParentType': erParentType,
      'PayItems': payItems.map((item) => item.toJson()).toList(),
      'E': e,
    };
  }

  factory BondModel.empty({required BondType bondType, int lastBondNumber = 0}) {
    return BondModel(
      payItems: [],
      payNumber: lastBondNumber + 1,
      payTypeGuid: bondType,
    );
  }

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat() {
    // TODO: implement toPlutoGridFormat
    throw UnimplementedError();
  }

  factory BondModel.fromBondData(
      {BondModel? bondModel,
      required BondType bondType,
      required note,
      required String bondCustomerId,
      required String bondSellerId,
      required int bondPayType,
      required String bondDate,
      required double bondTotal,
      required double bondVatTotal,
      required double bondWithoutVatTotal,
      required double bondGiftsTotal,
      required double bondDiscountsTotal,
      required double bondAdditionsTotal,
      required List<PayItem> bondRecordsItems}) {



    final items = PayItems.fromBondRecords(bondRecordsItems);

    return bondModel == null
        ? BondModel(

      payItems: items.itemList,
    )
        : bondModel.copyWith(
      bondTypeModel: bondTypeModel,
      bondDetails: bondDetails,
      items: items,
    );
  }

  BondModel copyWith({
    BondType? payTypeGuid,
    int? payNumber,
    String? payGuid,
    String? payBranchGuid,
    String? payDate,
    String? entryPostDate,
    String? payNote,
    String? payCurrencyGuid,
    double? payCurVal,
    String? payAccountGuid,
    int? paySecurity,
    int? paySkip,
    int? erParentType,
    List<PayItem>? payItems,
    String? e,
  }) {
    return BondModel(
      payTypeGuid: payTypeGuid ?? this.payTypeGuid,
      payNumber: payNumber ?? this.payNumber,
      payGuid: payGuid ?? this.payGuid,
      payBranchGuid: payBranchGuid ?? this.payBranchGuid,
      payDate: payDate ?? this.payDate,
      entryPostDate: entryPostDate ?? this.entryPostDate,
      payNote: payNote ?? this.payNote,
      payCurrencyGuid: payCurrencyGuid ?? this.payCurrencyGuid,
      payCurVal: payCurVal ?? this.payCurVal,
      payAccountGuid: payAccountGuid ?? this.payAccountGuid,
      paySecurity: paySecurity ?? this.paySecurity,
      paySkip: paySkip ?? this.paySkip,
      erParentType: erParentType ?? this.erParentType,
      payItems: payItems ?? this.payItems,
      e: e ?? this.e,
    );
  }
}
