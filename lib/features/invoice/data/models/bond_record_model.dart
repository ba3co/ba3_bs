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
}
