import '../../../patterns/data/models/bill_type_model.dart';

class BillModel {
  final String? billId;
  final BillTypeModel billTypeModel;

  final BillItems items;
  final BillDetails billDetails;

  BillModel({
    this.billId,
    required this.billTypeModel,
    required this.items,
    required this.billDetails,
  });

  BillModel copyWith({
    final String? billId,
    final BillTypeModel? billTypeModel,
    final BillItems? items,
    final BillDetails? billDetails,
  }) {
    return BillModel(
      billId: billId ?? this.billId,
      billTypeModel: billTypeModel ?? this.billTypeModel,
      items: items ?? this.items,
      billDetails: billDetails ?? this.billDetails,
    );
  }

  factory BillModel.fromJson(Map<String, dynamic> json) {
    return BillModel(
      billId: json['billId'],
      billTypeModel: BillTypeModel.fromJson(json['billTypeModel']),
      billDetails: BillDetails.fromJson(json['billDetails']),
      items: BillItems.fromJson(json['items']),
    );
  }

  Map<String, dynamic> toJson() => {
        'billId': billId,
        'billTypeModel': billTypeModel.toJson(),
        'billDetails': billDetails.toJson(),
        'items': items.toJson(),
      };
}

class BillDetails {
  final String? billGuid;
  final int? billPayType;
  final int? billNumber;
  final String? billDate;
  final String? note;
  final String? billSellerId;
  final String? billCustomerId;
  final double? billTotal;
  final double? billVatTotal;
  final double? billGiftsTotal;
  final double? billDiscountsTotal;
  final double? billAdditionsTotal;

  BillDetails({
    this.billGuid,
    this.billPayType,
    this.billNumber,
    this.billDate,
    this.note,
    this.billCustomerId,
    this.billTotal,
    this.billSellerId,
    this.billVatTotal,
    this.billGiftsTotal,
    this.billDiscountsTotal,
    this.billAdditionsTotal,
  });

  BillDetails copyWith({
    final String? billGuid,
    final int? billPayType,
    final int? billNumber,
    final String? billDate,
    final String? note,
    final String? billCustomerId,
    final String? billSellerId,
    final double? billTotal,
    final double? billVatTotal,
    final double? billGiftsTotal,
    final double? billDiscountsTotal,
    final double? billAdditionsTotal,
  }) {
    return BillDetails(
      billGuid: billGuid ?? this.billGuid,
      billPayType: billPayType ?? this.billPayType,
      billNumber: billNumber ?? this.billNumber,
      billDate: billDate ?? this.billDate,
      note: note ?? this.note,
      billTotal: billTotal ?? this.billTotal,
      billCustomerId: billCustomerId ?? this.billCustomerId,
      billSellerId: billSellerId ?? this.billSellerId,
      billVatTotal: billVatTotal ?? this.billVatTotal,
      billDiscountsTotal: billDiscountsTotal ?? this.billDiscountsTotal,
      billGiftsTotal: billGiftsTotal ?? this.billGiftsTotal,
      billAdditionsTotal: billAdditionsTotal ?? this.billAdditionsTotal,
    );
  }

  factory BillDetails.fromJson(Map<String, dynamic> json) {
    return BillDetails(
      billGuid: json['billGuid'],
      billPayType: json['billPayType'],
      billNumber: json['billNumber'],
      billDate: json['billDate'],
      note: json['note'],
      billCustomerId: json['billCustomerId'],
      billTotal: json['billTotal'],
      billSellerId: json['billSellerId'],
      billVatTotal: json['billVatTotal'],
      billGiftsTotal: json['billGiftsTotal'],
      billDiscountsTotal: json['billDiscountsTotal'],
      billAdditionsTotal: json['billAdditionsTotal'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billGuid': billGuid,
      'billPayType': billPayType,
      'billNumber': billNumber,
      'billDate': billDate,
      'note': note,
      'billCustomerId': billCustomerId,
      'billTotal': billTotal,
      'billSellerId': billSellerId,
      'billVatTotal': billVatTotal,
      'billGiftsTotal': billGiftsTotal,
      'billDiscountsTotal': billDiscountsTotal,
      'billAdditionsTotal': billAdditionsTotal,
    };
  }
}

class BillItems {
  final List<BillItem> itemList;

  BillItems({required this.itemList});

  BillItems copyWith({List<BillItem>? itemList}) {
    return BillItems(
      itemList: itemList ?? this.itemList,
    );
  }

  factory BillItems.fromJson(Map<String, dynamic> json) {
    var itemsJson = json['Item'] as List<dynamic>;
    List<BillItem> itemList = itemsJson.map((item) => BillItem.fromJson(item)).toList();
    return BillItems(itemList: itemList);
  }

  Map<String, dynamic> toJson() => {
        'Item': itemList.map((item) => item.toJson()).toList(),
      };
}

class BillItem {
  final String itemGuid;
  final String itemName;
  final int itemQuantity;
  final String itemTotalPrice;
  final double? itemSubTotalPrice;
  final double? itemVatPrice;
  final int? itemGiftsNumber;
  final double? itemGiftsPrice;

  BillItem({
    required this.itemGuid,
    required this.itemName,
    required this.itemQuantity,
    required this.itemTotalPrice,
    this.itemSubTotalPrice,
    this.itemVatPrice,
    this.itemGiftsNumber,
    this.itemGiftsPrice,
  });

  BillItem copyWith({
    final String? itemGuid,
    final String? itemName,
    final int? itemQuantity,
    final String? itemTotalPrice,
    final double? itemSubTotalPrice,
    final double? itemVatPrice,
    final int? itemGiftsNumber,
    final double? itemGiftsPrice,
  }) {
    return BillItem(
      itemGuid: itemGuid ?? this.itemGuid,
      itemName: itemName ?? this.itemName,
      itemQuantity: itemQuantity ?? this.itemQuantity,
      itemTotalPrice: itemTotalPrice ?? this.itemTotalPrice,
      itemSubTotalPrice: itemSubTotalPrice ?? this.itemSubTotalPrice,
      itemVatPrice: itemVatPrice ?? this.itemVatPrice,
      itemGiftsNumber: itemGiftsNumber ?? this.itemGiftsNumber,
      itemGiftsPrice: itemGiftsPrice ?? this.itemGiftsPrice,
    );
  }

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      itemGuid: json['ItemGuid'],
      itemName: json['ItemName'],
      itemQuantity: json['ItemQuantity'],
      itemTotalPrice: json['itemTotalPrice'],
      itemSubTotalPrice: json['itemSubTotalPrice'],
      itemVatPrice: json['itemVatPrice'],
      itemGiftsNumber: json['itemGiftsNumber'],
      itemGiftsPrice: json['itemGiftsPrice'],
    );
  }

  Map<String, dynamic> toJson() => {
        'ItemGuid': itemGuid,
        'ItemName': itemName,
        'ItemQuantity': itemQuantity,
        'itemTotalPrice': itemTotalPrice,
        'itemSubTotalPrice': itemSubTotalPrice,
        'itemVatPrice': itemVatPrice,
        'itemGiftsNumber': itemGiftsNumber,
        'itemGiftsPrice': itemGiftsPrice,
      };
}
