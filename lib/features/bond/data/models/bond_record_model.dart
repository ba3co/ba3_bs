import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';

class BondItemModel implements PlutoAdaptable {
  final BondItemType? bondItemType;

  final double? amount;

  final AccountModel? account, oppositeAccount;
  final String? note;

  BondItemModel({
    this.bondItemType,
    this.amount,
    this.account,
    this.oppositeAccount,
    this.note,
  });

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat() {
    return {
      PlutoColumn(
        title: AppConstants.bondRecordBondItemType,
        type: PlutoColumnType.text(),
        field: AppConstants.bondRecordBondItemType,
      ): bondItemType,
      PlutoColumn(
        title: AppConstants.bondRecordAccount,
        type: PlutoColumnType.text(),
        field: AppConstants.bondRecordAccount,
      ): amount,
      PlutoColumn(
        title: "account",
        type: PlutoColumnType.text(),
        field: 'account',
      ): account,
      PlutoColumn(
        title: "note",
        type: PlutoColumnType.text(),
        field: 'note',
      ): note,
    };
  }

  Map<PlutoColumn, dynamic> toPlutoGridFormatWithType(bool isDebitOrCredit) {
    if (!isDebitOrCredit) {
      return {
        PlutoColumn(
          title: "amount",
          type: PlutoColumnType.text(),
          field: 'amount',
        ): amount,
        PlutoColumn(
          title: "account",
          type: PlutoColumnType.text(),
          field: 'account',
        ): account,
        PlutoColumn(
          title: "note",
          type: PlutoColumnType.text(),
          field: 'note',
        ): note,
      };
    } else {
      return {
        PlutoColumn(
          title: "debit",
          type: PlutoColumnType.text(),
          field: 'debit',
        ):bondItemType==BondItemType.debtor?0: amount,
        PlutoColumn(
          title: "credit",
          type: PlutoColumnType.text(),
          field: 'credit',
        ): amount,
        PlutoColumn(
          title: "account",
          type: PlutoColumnType.text(),
          field: 'account',
        ):bondItemType==BondItemType.creditor?0: amount,
        PlutoColumn(
          title: "note",
          type: PlutoColumnType.text(),
          field: 'note',
        ): note,
      };
    }
  }

  factory BondItemModel.fromPlutoJson(Map<String, dynamic> json) {
    return BondItemModel(
      bondItemType: double.parse(json['debit'].toString())>0?BondItemType.debtor:BondItemType.creditor,
      note: "",
      oppositeAccount: AccountModel(),
      account: AccountModel(),
      amount: 4,
    );
  }
}

class BondModel {
  final Map<AccountModel, List<BondItemModel>> bonds;

  BondModel({
    required this.bonds,
  });
}
