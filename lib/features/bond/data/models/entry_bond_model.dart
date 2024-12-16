

import '../../../../core/helper/enums/enums.dart';

class EntryBondItemModel  {
  final BondItemType? bondItemType;
  final double? amount;
  final String? account;
  final String? note;
  final String? organGuid;


  EntryBondItemModel({
    this.bondItemType,
    this.amount,
    this.account,
    this.note,
    this.organGuid,
  });

}

class EntryBondModel {
  final List<EntryBondItemModel>? bonds;

  EntryBondModel({
    required this.bonds,
  });
}


