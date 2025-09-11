import 'package:hive/hive.dart';

import '../../../accounts/data/models/account_model.dart';

part 'discount_addition_account_model.g.dart';

@HiveType(typeId: 11)
class DiscountAdditionAccountModel extends AccountModel {
  @HiveField(26)
  double amount; // Add amount for discount/addition

  @HiveField(27)
  double percentage; // Add percentage for discount/addition

  DiscountAdditionAccountModel({
    required String accName,
    required String id,
    required this.amount,
    required this.percentage,
  }) : super(accName: accName, id: id);

  factory DiscountAdditionAccountModel.fromJson(Map<String, dynamic> json) {
    return DiscountAdditionAccountModel(
      accName: json['accName'],
      id: json['id'],
      amount: json['amount'],
      percentage: json['percentage'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'accName': accName,
      'id': id,
      'amount': amount,
      'percentage': percentage,
    };
  }
}
