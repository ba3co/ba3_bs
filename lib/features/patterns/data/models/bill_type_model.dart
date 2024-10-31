import '../../../pluto/data/models/pluto_adaptable.dart';

class BillTypeModel implements PlutoAdaptable {
  final String? id;
  final String? shortName;
  final String? fullName;
  final String? latinShortName;
  final String? latinFullName;
  final String? billTypeLabel;
  final String? materialAccount;
  final String? discountsAccount;
  final String? additionsAccount;
  final String? cashesAccount;
  final String? giftsAccount;
  final String? exchangeForGiftsAccount;
  final int? color;
  final String? store;

  BillTypeModel({
    this.id,
    this.shortName,
    this.fullName,
    this.latinShortName,
    this.latinFullName,
    this.billTypeLabel,
    this.materialAccount,
    this.discountsAccount,
    this.additionsAccount,
    this.cashesAccount,
    this.giftsAccount,
    this.exchangeForGiftsAccount,
    this.color,
    this.store,
  });

  factory BillTypeModel.fromJson(Map<String, dynamic> json) {
    return BillTypeModel(
      id: json['id'],
      shortName: json['shortName'],
      fullName: json['fullName'],
      latinShortName: json['latinShortName'],
      latinFullName: json['latinFullName'],
      billTypeLabel: json['billType'],
      materialAccount: json['materialAccount'],
      discountsAccount: json['discountsAccount'],
      additionsAccount: json['additionsAccount'],
      cashesAccount: json['cashesAccount'],
      giftsAccount: json['giftsAccount'],
      exchangeForGiftsAccount: json['exchangeForGiftsAccount'],
      color: json['color'],
      store: json['store'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shortName': shortName,
        'fullName': fullName,
        'latinShortName': latinShortName,
        'latinFullName': latinFullName,
        'billType': billTypeLabel,
        'materialAccount': materialAccount,
        'discountsAccount': discountsAccount,
        'additionsAccount': additionsAccount,
        'cashesAccount': cashesAccount,
        'giftsAccount': giftsAccount,
        'exchangeForGiftsAccount': exchangeForGiftsAccount,
        'color': color,
        'store': store,
      };

  // Copy with method for creating a new instance with some modified fields
  BillTypeModel copyWith({
    String? id,
    String? shortName,
    String? fullName,
    String? latinShortName,
    String? latinFullName,
    String? billTypeLabel,
    String? materialAccount,
    String? discountsAccount,
    String? additionsAccount,
    String? cashesAccount,
    String? giftsAccount,
    String? exchangeForGiftsAccount,
    int? color,
    String? store,
  }) =>
      BillTypeModel(
        id: id ?? this.id,
        shortName: shortName ?? this.shortName,
        fullName: fullName ?? this.fullName,
        latinShortName: latinShortName ?? this.latinShortName,
        latinFullName: latinFullName ?? this.latinFullName,
        billTypeLabel: billTypeLabel ?? this.billTypeLabel,
        materialAccount: materialAccount ?? this.materialAccount,
        discountsAccount: discountsAccount ?? this.discountsAccount,
        additionsAccount: additionsAccount ?? this.additionsAccount,
        cashesAccount: cashesAccount ?? this.cashesAccount,
        giftsAccount: giftsAccount ?? this.giftsAccount,
        exchangeForGiftsAccount: exchangeForGiftsAccount ?? this.exchangeForGiftsAccount,
        color: color ?? this.color,
        store: store ?? this.store,
      );

  @override
  Map<String, dynamic> toPlutoGridFormat() => {
        'id': id,
        'shortName': shortName,
        'fullName': fullName,
        'latinShortName': latinShortName,
        'latinFullName': latinFullName,
        'billType': billTypeLabel,
        'materialAccount': materialAccount,
        'discountsAccount': discountsAccount,
        'additionsAccount': additionsAccount,
        'cashesAccount': cashesAccount,
        'giftsAccount': giftsAccount,
        'exchangeForGiftsAccount': exchangeForGiftsAccount,
        'color': color,
        'store': store,
      };
}
