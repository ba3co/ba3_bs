import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';

class BondItemModel implements PlutoAdaptable {
  final BondItemType bondItemType;

  final double amount;

  final AccountModel account, oppositeAccount;
  final String note;

  BondItemModel({
    required this.bondItemType,
    required this.amount,
    required this.account,
    required this.oppositeAccount,
    required this.note,
  });

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat() {
    return {
      PlutoColumn(
        title: "bondItemType",
        type: PlutoColumnType.text(),
        field: 'bondItemType',
      ): bondItemType,
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
  }

 factory  BondItemModel.fromPlutoJson(Map<String, dynamic> json) {
    return BondItemModel(
      bondItemType: json['bondRecAccount'],
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
