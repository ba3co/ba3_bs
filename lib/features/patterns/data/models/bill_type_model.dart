class BillTypeModel {
  final String? id;
  final String? shortName;
  final String? fullName;
  final String? latinShortName;
  final String? latinFullName;
  final String? billType;
  final String? materialAccount; // المواد
  final String? discountsAccount; // الحسميات
  final String? additionsAccount; //الاضافات
  final String? cashesAccount; // النقديات
  final String? giftsAccount; // الهدايا
  final String? exchangeForGiftsAccount; // مقابل الهدايا
  final int? color;
  final String? store;

  BillTypeModel({
    this.id,
    this.shortName,
    this.fullName,
    this.latinShortName,
    this.latinFullName,
    this.billType,
    this.materialAccount,
    this.discountsAccount,
    this.additionsAccount,
    this.cashesAccount,
    this.giftsAccount,
    this.exchangeForGiftsAccount,
    this.color,
    this.store,
  });

  factory BillTypeModel.fromJson(Map json) => BillTypeModel(
        id: json['id'],
        shortName: json['shortName'],
        fullName: json['fullName'],
        latinShortName: json['latinShortName'],
        latinFullName: json['latinFullName'],
        billType: json['billType'],
        materialAccount: json['materialAccount'],
        discountsAccount: json['discountsAccount'],
        additionsAccount: json['additionsAccount'],
        cashesAccount: json['cashesAccount'],
        giftsAccount: json['giftsAccount'],
        exchangeForGiftsAccount: json['exchangeForGiftsAccount'],
        color: json['color'],
        store: json['store'],
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shortName': shortName,
      'fullName': fullName,
      'latinShortName': latinShortName,
      'latinFullName': latinFullName,
      'billType': billType,
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

  // Convert the object into a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'Short Arabic Name': shortName,
      'Full Arabic Name': fullName,
      'Short Latin Name': latinShortName,
      'Full Latin Name': latinFullName,
      'Bill Type': billType,
      'Material Account': materialAccount,
      'Discounts Account': discountsAccount,
      'Additions Account': additionsAccount,
      'Cash Account': cashesAccount,
      'Gifts Account': giftsAccount,
      'Exchange for Gifts Account': exchangeForGiftsAccount,
      'Color': color,
      'Store': store,
    };
  }

  // Copy with method for creating a new instance with some modified fields
  BillTypeModel copyWith({
    String? id,
    String? shortName,
    String? fullName,
    String? latinShortName,
    String? latinFullName,
    String? billType,
    String? materialAccount,
    String? discountsAccount,
    String? additionsAccount,
    String? cashesAccount,
    String? giftsAccount,
    String? exchangeForGiftsAccount,
    int? color,
    String? store,
  }) {
    return BillTypeModel(
      id: id ?? this.id,
      shortName: shortName ?? this.shortName,
      fullName: fullName ?? this.fullName,
      latinShortName: latinShortName ?? this.latinShortName,
      latinFullName: latinFullName ?? this.latinFullName,
      billType: billType ?? this.billType,
      materialAccount: materialAccount ?? this.materialAccount,
      discountsAccount: discountsAccount ?? this.discountsAccount,
      additionsAccount: additionsAccount ?? this.additionsAccount,
      cashesAccount: cashesAccount ?? this.cashesAccount,
      giftsAccount: giftsAccount ?? this.giftsAccount,
      exchangeForGiftsAccount: exchangeForGiftsAccount ?? this.exchangeForGiftsAccount,
      color: color ?? this.color,
      store: store ?? this.store,
    );
  }
}
