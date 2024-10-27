import '../../../../core/base_classes/sales_account.dart';
import '../../../../core/helper/enums/enums.dart';

class BondItemModel {
  final BondItemType bondItemType;

  final double amount;

  BondItemModel({
    required this.bondItemType,
    required this.amount,
  });
}

class BondModel {
  final Map<SalesAccount, List<BondItemModel>> bonds;

  BondModel({
    required this.bonds,
  });
}

class BondRecordModel {
  final String? bondRecId;
  final String? bondRecAccount;
  final String? bondRecDescription;
  final String? invId;
  final double? bondRecCreditAmount;
  final double? bondRecDebitAmount;

  BondRecordModel({
    required this.bondRecId,
    required this.bondRecCreditAmount,
    required this.bondRecDebitAmount,
    required this.bondRecAccount,
    required this.bondRecDescription,
    required this.invId,
  });

  BondRecordModel copyWith({
    String? bondRecId,
    String? bondRecAccount,
    String? bondRecDescription,
    String? invId,
    double? bondRecCreditAmount,
    double? bondRecDebitAmount,
  }) {
    return BondRecordModel(
      bondRecId: bondRecId ?? this.bondRecId,
      bondRecAccount: bondRecAccount ?? this.bondRecAccount,
      bondRecDescription: bondRecDescription ?? this.bondRecDescription,
      invId: invId ?? this.invId,
      bondRecCreditAmount: bondRecCreditAmount ?? this.bondRecCreditAmount,
      bondRecDebitAmount: bondRecDebitAmount ?? this.bondRecDebitAmount,
    );
  }
}
