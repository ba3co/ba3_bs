

import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';

class EntryBondItemModel  {
  final BondItemType? bondItemType;
  final double? amount;
  final AccountModel? account, oppositeAccount;
  final String? note;

  EntryBondItemModel({
    this.bondItemType,
    this.amount,
    this.account,
    this.oppositeAccount,
    this.note,
  });

/* factory EntryBondItemModel.fromJson(Map<String, dynamic> json) {
    return EntryBondItemModel(
      bondItemType: BondItemType.values.firstWhere(
        (e) => e.label == json['bondItemType'],
        // orElse: () => null,
      ),
      amount: (json['amount'] as num?)?.toDouble(),
      account: json['account'] != null ? AppServiceUtils.getAccountModelFromLabel(json['account']) : null,
      oppositeAccount:
          json['oppositeAccount'] != null ? AppServiceUtils.getAccountModelFromLabel(json['oppositeAccount']) : null,
      note: json['note'],
    );
  }



  factory EntryBondItemModel.fromJsonPluto({
    required String account,
    required String note,
    required BondItemType bondType,
    required double amount,
  }) {
    return EntryBondItemModel(
      amount: amount,
      account: AppServiceUtils.getAccountModelFromLabel(account),
      bondItemType: bondType,
      note: note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bondItemType': bondItemType!.label, // تحويل enum إلى نص
      'amount': amount,
      'account': account?.accName, // تأكد أن AccountModel يدعم toJson
      'oppositeAccount': oppositeAccount?.accName,
      'note': note,
    };
  }*/
}

class EntryBondModel {
  final Map<AccountModel, List<EntryBondItemModel>> bonds;

  EntryBondModel({
    required this.bonds,
  });
}


