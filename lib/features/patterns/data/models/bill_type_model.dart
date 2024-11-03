import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../pluto/data/models/pluto_adaptable.dart';

class BillTypeModel implements PlutoAdaptable {
  final String? id;
  final String? shortName;
  final String? fullName;
  final String? latinShortName;
  final String? latinFullName;
  final String? billTypeLabel;
  final int? color;

  // Using a map to store accounts with Account as the key and AccountModel as the value
  final Map<Account, AccountModel>? accounts;

  BillTypeModel({
    this.id,
    this.shortName,
    this.fullName,
    this.latinShortName,
    this.latinFullName,
    this.billTypeLabel,
    this.color,
    this.accounts,
  });

  factory BillTypeModel.fromJson(Map<String, dynamic> json) {
    return BillTypeModel(
      id: json['id'],
      shortName: json['shortName'],
      fullName: json['fullName'],
      latinShortName: json['latinShortName'],
      latinFullName: json['latinFullName'],
      billTypeLabel: json['billType'],
      color: json['color'],
      // Deserialize accounts map
      accounts: (json['accounts'] as Map<String, dynamic>?)?.map((billAccountLabel, accountModelJson) {
        Account billAccount = getBillAccountFromLabel(billAccountLabel);
        AccountModel accountModel = AccountModel.fromMap(accountModelJson);
        return MapEntry(billAccount, accountModel);
      }),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shortName': shortName,
        'fullName': fullName,
        'latinShortName': latinShortName,
        'latinFullName': latinFullName,
        'billType': billTypeLabel,
        'color': color,
        // Serialize accounts map
        'accounts': accounts?.map((billAccounts, accountModel) => MapEntry(billAccounts.label, accountModel.toMap())),
      };

  BillTypeModel copyWith({
    String? id,
    String? shortName,
    String? fullName,
    String? latinShortName,
    String? latinFullName,
    String? billTypeLabel,
    int? color,
    String? store,
    Map<Account, AccountModel>? accounts,
  }) =>
      BillTypeModel(
        id: id ?? this.id,
        shortName: shortName ?? this.shortName,
        fullName: fullName ?? this.fullName,
        latinShortName: latinShortName ?? this.latinShortName,
        latinFullName: latinFullName ?? this.latinFullName,
        billTypeLabel: billTypeLabel ?? this.billTypeLabel,
        color: color ?? this.color,
        accounts: accounts ?? this.accounts,
      );

  @override
  Map<String, dynamic> toPlutoGridFormat() => {
        'id': id,
        'shortName': shortName,
        'fullName': fullName,
        'latinShortName': latinShortName,
        'latinFullName': latinFullName,
        'billType': billTypeLabel,
        'color': color,
        'accounts': accounts?.map((key, value) => MapEntry(key.label, value.toPlutoGridFormat())),
      };
}

// Utility function to get an Account object from a string
Account getBillAccountFromLabel(String label) => BillAccounts.fromLabel(label);
