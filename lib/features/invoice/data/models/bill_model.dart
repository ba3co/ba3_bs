import '../../../patterns/data/models/bill_type_model.dart';

class BillModel {
  final String? id;
  final BillTypeModel billTypeModel;
  final String? disc;
  final Items items;

  BillModel({
    this.id,
    required this.billTypeModel,
    this.disc,
    required this.items,
  });

  BillModel copyWith({
    final String? id,
    final BillTypeModel? billTypeModel,
    final String? disc,
    final Items? items,
  }) {
    return BillModel(
      id: id ?? this.id,
      billTypeModel: billTypeModel ?? this.billTypeModel,
      disc: disc ?? this.disc,
      items: items ?? this.items,
    );
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      id: json['id'],
      billTypeModel: BillTypeModel.fromJson(json['billTypeModel']),
      disc: json['disc'] as String,
      items: Items.fromJson(json['items']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'billTypeModel': billTypeModel.toJson(),
        'disc': disc,
        'items': items.toJson(),
      };
}

class BillDetails {
  final String? billTypeGuid;
  final String? billGuid;
  final String? billBranch;
  final int? billPayType;
  final String? billCheckTypeGuid;
  final int? billNumber;
  final String? billCustPtr;
  final String? billCustName;
  final String? billCurrencyGuid;
  final double? billCurrencyVal;
  final String? billDate;
  final String? billStoreGuid;
  final String? note;
  final String? billCustAcc;
  final String? billMatAccGuid;
  final String? billCostGuid;
  final String? billVendorSalesMan;
  final double? billFirstPay;
  final String? billFPayAccGuid;
  final int? billSecurity;
  final String? billTransferGuid;
  final String? billFld1;
  final String? billFld2;
  final String? billFld3;
  final String? billFld4;
  final String? itemsDiscAcc;
  final String? itemsExtraAccGUID;
  final String? costAccGUID;
  final String? stockAccGUID;
  final String? bonusAccGUID;
  final String? bonusContraAccGUID;
  final String? vatAccGUID;
  final String? discCard;
  final String? billAddressGUID;

  BillDetails({
    this.billTypeGuid,
    this.billGuid,
    this.billBranch,
    this.billPayType,
    this.billCheckTypeGuid,
    this.billNumber,
    this.billCustPtr,
    this.billCustName,
    this.billCurrencyGuid,
    this.billCurrencyVal,
    this.billDate,
    this.billStoreGuid,
    this.note,
    this.billCustAcc,
    this.billMatAccGuid,
    this.billCostGuid,
    this.billVendorSalesMan,
    this.billFirstPay,
    this.billFPayAccGuid,
    this.billSecurity,
    this.billTransferGuid,
    this.billFld1,
    this.billFld2,
    this.billFld3,
    this.billFld4,
    this.itemsDiscAcc,
    this.itemsExtraAccGUID,
    this.costAccGUID,
    this.stockAccGUID,
    this.bonusAccGUID,
    this.bonusContraAccGUID,
    this.vatAccGUID,
    this.discCard,
    this.billAddressGUID,
  });

  BillDetails copyWith({
    String? billTypeGuid,
    String? billGuid,
    String? billBranch,
    int? billPayType,
    String? billCheckTypeGuid,
    int? billNumber,
    String? billCustPtr,
    String? billCustName,
    String? billCurrencyGuid,
    double? billCurrencyVal,
    String? billDate,
    String? billStoreGuid,
    String? note,
    String? billCustAcc,
    String? billMatAccGuid,
    String? billCostGuid,
    String? billVendorSalesMan,
    double? billFirstPay,
    String? billFPayAccGuid,
    int? billSecurity,
    String? billTransferGuid,
    String? billFld1,
    String? billFld2,
    String? billFld3,
    String? billFld4,
    String? itemsDiscAcc,
    String? itemsExtraAccGUID,
    String? costAccGUID,
    String? stockAccGUID,
    String? bonusAccGUID,
    String? bonusContraAccGUID,
    String? vatAccGUID,
    String? discCard,
    String? billAddressGUID,
  }) {
    return BillDetails(
      billTypeGuid: billTypeGuid ?? this.billTypeGuid,
      billGuid: billGuid ?? this.billGuid,
      billBranch: billBranch ?? this.billBranch,
      billPayType: billPayType ?? this.billPayType,
      billCheckTypeGuid: billCheckTypeGuid ?? this.billCheckTypeGuid,
      billNumber: billNumber ?? this.billNumber,
      billCustPtr: billCustPtr ?? this.billCustPtr,
      billCustName: billCustName ?? this.billCustName,
      billCurrencyGuid: billCurrencyGuid ?? this.billCurrencyGuid,
      billCurrencyVal: billCurrencyVal ?? this.billCurrencyVal,
      billDate: billDate ?? this.billDate,
      billStoreGuid: billStoreGuid ?? this.billStoreGuid,
      note: note ?? this.note,
      billCustAcc: billCustAcc ?? this.billCustAcc,
      billMatAccGuid: billMatAccGuid ?? this.billMatAccGuid,
      billCostGuid: billCostGuid ?? this.billCostGuid,
      billVendorSalesMan: billVendorSalesMan ?? this.billVendorSalesMan,
      billFirstPay: billFirstPay ?? this.billFirstPay,
      billFPayAccGuid: billFPayAccGuid ?? this.billFPayAccGuid,
      billSecurity: billSecurity ?? this.billSecurity,
      billTransferGuid: billTransferGuid ?? this.billTransferGuid,
      billFld1: billFld1 ?? this.billFld1,
      billFld2: billFld2 ?? this.billFld2,
      billFld3: billFld3 ?? this.billFld3,
      billFld4: billFld4 ?? this.billFld4,
      itemsDiscAcc: itemsDiscAcc ?? this.itemsDiscAcc,
      itemsExtraAccGUID: itemsExtraAccGUID ?? this.itemsExtraAccGUID,
      costAccGUID: costAccGUID ?? this.costAccGUID,
      stockAccGUID: stockAccGUID ?? this.stockAccGUID,
      bonusAccGUID: bonusAccGUID ?? this.bonusAccGUID,
      bonusContraAccGUID: bonusContraAccGUID ?? this.bonusContraAccGUID,
      vatAccGUID: vatAccGUID ?? this.vatAccGUID,
      discCard: discCard ?? this.discCard,
      billAddressGUID: billAddressGUID ?? this.billAddressGUID,
    );
  }

  factory BillDetails.fromJson(Map<String, dynamic> json) {
    return BillDetails(
      billTypeGuid: json['BillTypeGuid'],
      billGuid: json['BillGuid'],
      billBranch: json['BillBranch'],
      billPayType: json['BillPayType'],
      billCheckTypeGuid: json['BillCheckTypeGuid'],
      billNumber: json['BillNumber'],
      billCustPtr: json['BillCustPtr'],
      billCustName: json['BillCustName'],
      billCurrencyGuid: json['BillCurrencyGuid'],
      billCurrencyVal: json['BillCurrencyVal'].toDouble(),
      billDate: json['BillDate'],
      billStoreGuid: json['BillStoreGuid'],
      note: json['Note'],
      billCustAcc: json['BillCustAcc'],
      billMatAccGuid: json['BillMatAccGuid'],
      billCostGuid: json['BillCostGuid'],
      billVendorSalesMan: json['BillVendorSalesMan'],
      billFirstPay: json['BillFirstPay'].toDouble(),
      billFPayAccGuid: json['BillFPayAccGuid'],
      billSecurity: json['BillSecurity'],
      billTransferGuid: json['BillTransferGuid'],
      billFld1: json['BillFld1'],
      billFld2: json['BillFld2'],
      billFld3: json['BillFld3'],
      billFld4: json['BillFld4'],
      itemsDiscAcc: json['ItemsDiscAcc'],
      itemsExtraAccGUID: json['ItemsExtraAccGUID'],
      costAccGUID: json['CostAccGUID'],
      stockAccGUID: json['StockAccGUID'],
      bonusAccGUID: json['BonusAccGUID'],
      bonusContraAccGUID: json['BonusContraAccGUID'],
      vatAccGUID: json['VATAccGUID'],
      discCard: json['DIscCard'],
      billAddressGUID: json['BillAddressGUID'],
    );
  }

  Map<String, dynamic> toJson() => {
        'BillTypeGuid': billTypeGuid,
        'BillGuid': billGuid,
        'BillBranch': billBranch,
        'BillPayType': billPayType,
        'BillCheckTypeGuid': billCheckTypeGuid,
        'BillNumber': billNumber,
        'BillCustPtr': billCustPtr,
        'BillCustName': billCustName,
        'BillCurrencyGuid': billCurrencyGuid,
        'BillCurrencyVal': billCurrencyVal,
        'BillDate': billDate,
        'BillStoreGuid': billStoreGuid,
        'Note': note,
        'BillCustAcc': billCustAcc,
        'BillMatAccGuid': billMatAccGuid,
        'BillCostGuid': billCostGuid,
        'BillVendorSalesMan': billVendorSalesMan,
        'BillFirstPay': billFirstPay,
        'BillFPayAccGuid': billFPayAccGuid,
        'BillSecurity': billSecurity,
        'BillTransferGuid': billTransferGuid,
        'BillFld1': billFld1,
        'BillFld2': billFld2,
        'BillFld3': billFld3,
        'BillFld4': billFld4,
        'ItemsDiscAcc': itemsDiscAcc,
        'ItemsExtraAccGUID': itemsExtraAccGUID,
        'CostAccGUID': costAccGUID,
        'StockAccGUID': stockAccGUID,
        'BonusAccGUID': bonusAccGUID,
        'BonusContraAccGUID': bonusContraAccGUID,
        'VATAccGUID': vatAccGUID,
        'DIscCard': discCard,
        'BillAddressGUID': billAddressGUID,
      };
}

class Items {
  final List<Item> itemList;

  Items({required this.itemList});

  Items copyWith({List<Item>? itemList}) {
    return Items(
      itemList: itemList ?? this.itemList,
    );
  }

  factory Items.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['Item'] as List<dynamic>;
    List<Item> itemList = itemsJson.map((item) => Item.fromJson(item)).toList();
    return Items(itemList: itemList);
  }

  Map<String, dynamic> toJson() => {
        'Item': itemList.map((item) => item.toJson()).toList(),
      };
}

class Item {
  final String itemGuid;
  final String itemName;
  final int itemQuantity;
  final String itemPrice;

  Item({
    required this.itemGuid,
    required this.itemName,
    required this.itemQuantity,
    required this.itemPrice,
  });

  Item copyWith({
    String? itemGuid,
    String? itemName,
    int? itemQuantity,
    String? itemPrice,
  }) {
    return Item(
      itemGuid: itemGuid ?? this.itemGuid,
      itemName: itemName ?? this.itemName,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      itemPrice: itemPrice ?? this.itemPrice,
    );
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemGuid: json['ItemGuid'],
      itemName: json['ItemName'],
      itemQuantity: json['ItemQuantity'],
      itemPrice: json['ItemPrice'],
    );
  }

  Map<String, dynamic> toJson() => {
        'ItemGuid': itemGuid,
        'ItemName': itemName,
        'ItemQuantity': itemQuantity,
        'ItemPrice': itemPrice,
      };
}
