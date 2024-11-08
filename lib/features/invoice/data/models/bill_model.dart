import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:get/get.dart';

import '../../../patterns/data/models/bill_type_model.dart';
import 'invoice_record_model.dart';

class BillModel implements PlutoAdaptable {
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

  factory BillModel.fromInvoiceData({
    required double billVatTotal,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required double billTotal,
    required BillTypeModel billTypeModel,
    required List<InvoiceRecordModel> billItems,
  }) =>
      BillModel(
        billTypeModel: billTypeModel,
        billDetails: BillDetails(
          billTotal: billTotal,
          billVatTotal: billVatTotal,
          billGiftsTotal: billGiftsTotal,
          billDiscountsTotal: billDiscountsTotal,
          billAdditionsTotal: billAdditionsTotal,
        ),
        items: BillItems(
            itemList: billItems
                .map((invoiceRecordModel) => BillItem(
                      itemGuid: invoiceRecordModel.invRecId!,
                      itemName: invoiceRecordModel.invRecProduct!,
                      itemQuantity: invoiceRecordModel.invRecQuantity!,
                      itemTotalPrice: invoiceRecordModel.invRecTotal.toString(),
                      itemSubTotalPrice: invoiceRecordModel.invRecSubTotal,
                      itemVatPrice: invoiceRecordModel.invRecVat,
                      itemGiftsPrice: invoiceRecordModel.invRecGiftTotal,
                      itemGiftsNumber: invoiceRecordModel.invRecGift,
                    ))
                .toList()),
      );

  Map<String, dynamic> toJson() => {
        'billId': billId,
        'billTypeModel': billTypeModel.toJson(),
        'billDetails': billDetails.toJson(),
        'items': items.toJson(),
      };

  @override
  Map<String, dynamic> toPlutoGridFormat() => {
        'billId': billId ?? '',
        'التاريخ': billDetails.billDate ?? '',
        'المجموع الكلي': billDetails.billTotal ?? 0,
        'مجموع الضريبة': double.tryParse(billDetails.billVatTotal?.toStringAsFixed(2) ?? '0') ?? 0,
        'مجموع الحسم': billDetails.billDiscountsTotal ?? 0,
        'مجموع الهدايا': billDetails.billGiftsTotal ?? 0,
        'مجموع الاضافات': billDetails.billAdditionsTotal ?? 0,
        "نوع الفاتورة": BillType.fromLabel(billTypeModel.billTypeLabel ?? "").value,
        'نوع الدفع': InvPayType.fromIndex(billDetails.billPayType ?? 0).label,
        'حساب العميل': billTypeModel.accounts?[BillAccounts.caches]?.accName ?? '',
        'حساب البائع': Get.find<SellerController>().getSellerNameFromId(billDetails.billSellerId),
        'المستودع': billTypeModel.accounts?[BillAccounts.store] ?? '',
        'وصف': billDetails.note ?? '',
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

  Map<String, String> _createRecordRow(
          {required String id,
          bool isRatio = false,
          String discountRatio = '',
          String additionRatio = '',
          String discountValue = '',
          String additionValue = ''}) =>
      isRatio
          ? {
              'id': id,
              'discount': discountRatio,
              'addition': additionRatio,
            }
          : {
              'id': id,
              'discount': discountValue,
              'addition': additionValue,
            };

  List<Map<String, String>> get additionsDiscountsRecords {
    final double total = billTotal ?? 0;

    return [
      _createRecordRow(
        id: 'النسبه',
        isRatio: true,
        discountRatio: _calculateRatio(billDiscountsTotal ?? 0, total),
        additionRatio: _calculateRatio(billAdditionsTotal ?? 0, total),
      ),
      _createRecordRow(
        id: 'القيمة',
        isRatio: false,
        discountValue: (billDiscountsTotal ?? 0).toString(),
        additionValue: (billAdditionsTotal ?? 0).toString(),
      ),
    ];
  }

  String _calculateRatio(double value, double total) => total != 0 ? ((value / total) * 100).toStringAsFixed(0) : '0';
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

  List<InvoiceRecordModel> get materialRecords =>
      itemList.map((item) => InvoiceRecordModel.fromBillItem(item)).toList();
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
