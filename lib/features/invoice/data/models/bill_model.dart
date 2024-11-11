import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
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
  }) =>
      BillModel(
        billId: billId ?? this.billId,
        billTypeModel: billTypeModel ?? this.billTypeModel,
        items: items ?? this.items,
        billDetails: billDetails ?? this.billDetails,
      );

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        billId: json['billId'],
        billTypeModel: BillTypeModel.fromJson(json['billTypeModel']),
        billDetails: BillDetails.fromJson(json['billDetails']),
        items: BillItems.fromJson(json['items']),
      );

  factory BillModel.fromInvoiceData({
    BillModel? billModel,
    String? note,
    int? billNumber,
    required String billCustomerId,
    required String billSellerId,
    required int billPayType,
    required String billDate,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
    required double billTotal,
    required double billVatTotal,
    required double billWithoutVatTotal,
    required BillTypeModel billTypeModel,
    required List<InvoiceRecordModel> billItems,
  }) {
    final billDetails = _createBillDetails(
      existingDetails: billModel?.billDetails,
      note: note,
      billNumber: billNumber,
      billCustomerId: billCustomerId,
      billSellerId: billSellerId,
      billPayType: billPayType,
      billDate: billDate,
      billTotal: billTotal,
      billVatTotal: billVatTotal,
      billWithoutVatTotal: billWithoutVatTotal,
      billGiftsTotal: billGiftsTotal,
      billDiscountsTotal: billDiscountsTotal,
      billAdditionsTotal: billAdditionsTotal,
    );

    final items = _createBillItems(billItems);

    return billModel == null
        ? BillModel(
            billTypeModel: billTypeModel,
            billDetails: billDetails,
            items: items,
          )
        : billModel.copyWith(
            billTypeModel: billTypeModel,
            billDetails: billDetails,
            items: items,
          );
  }

  static BillDetails _createBillDetails({
    BillDetails? existingDetails,
    String? note,
    int? billNumber,
    required String billCustomerId,
    required String billSellerId,
    required int billPayType,
    required String billDate,
    required double billTotal,
    required double billVatTotal,
    required double billWithoutVatTotal,
    required double billGiftsTotal,
    required double billDiscountsTotal,
    required double billAdditionsTotal,
  }) =>
      BillDetails(
        billGuid: existingDetails?.billGuid,
        note: note,
        billNumber: billNumber,
        billCustomerId: billCustomerId,
        billSellerId: billSellerId,
        billPayType: billPayType,
        billDate: billDate,
        billTotal: billTotal,
        billVatTotal: billVatTotal,
        billWithoutVatTotal: billWithoutVatTotal,
        billGiftsTotal: billGiftsTotal,
        billDiscountsTotal: billDiscountsTotal,
        billAdditionsTotal: billAdditionsTotal,
      );

  static BillItems _createBillItems(List<InvoiceRecordModel> invoiceRecords) {
    final itemList = invoiceRecords.map((invoiceRecord) {
      return BillItem(
        itemGuid: invoiceRecord.invRecId!,
        itemName: invoiceRecord.invRecProduct!,
        itemQuantity: invoiceRecord.invRecQuantity!,
        itemTotalPrice: invoiceRecord.invRecTotal.toString(),
        itemSubTotalPrice: invoiceRecord.invRecSubTotal,
        itemVatPrice: invoiceRecord.invRecVat,
        itemGiftsPrice: invoiceRecord.invRecGiftTotal,
        itemGiftsNumber: invoiceRecord.invRecGift,
      );
    }).toList();

    return BillItems(itemList: itemList);
  }

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
        'مجموع الضريبة': double.tryParse(billDetails.billVatTotal?.toStringAsFixed(2) ?? '0') ?? 0,
        'المجموع قبل الضريبة': billDetails.billWithoutVatTotal ?? 0,
        'المجموع الكلي': billDetails.billTotal ?? 0,
        'مجموع الحسم': billDetails.billDiscountsTotal ?? 0,
        'مجموع الاضافات': billDetails.billAdditionsTotal ?? 0,
        'مجموع الهدايا': billDetails.billGiftsTotal ?? 0,
        'نوع الفاتورة': BillType.byLabel(billTypeModel.billTypeLabel ?? "").value,
        'نوع الدفع': InvPayType.fromIndex(billDetails.billPayType ?? 0).label,
        'حساب العميل': billTypeModel.accounts?[BillAccounts.caches]?.accName ?? '',
        'حساب البائع': Get.find<SellerController>().getSellerNameById(billDetails.billSellerId),
        'المستودع': billTypeModel.accounts?[BillAccounts.store] ?? '',
        'وصف': billDetails.note ?? '',
      };

  Map<String, String> _createRecordRow({required String id, required String discount, required String addition}) =>
      {AppConstants.id: id, AppConstants.discount: discount, AppConstants.addition: addition};

  String _calculateRatio(double value, double total) => total > 0 ? ((value / total) * 100).toStringAsFixed(0) : '0';

  double _partialTotal() => (billDetails.billVatTotal ?? 0) + (billDetails.billWithoutVatTotal ?? 0);

  List<Map<String, String>> get additionsDiscountsRecords {
    final partialTotal = _partialTotal();
    final discountTotal = (billDetails.billDiscountsTotal ?? 0).toString();
    final additionTotal = (billDetails.billAdditionsTotal ?? 0).toString();

    return [
      _createRecordRow(
        id: AppConstants.accountName,
        discount: billTypeModel.accounts?[BillAccounts.discounts]?.accName ?? '',
        addition: billTypeModel.accounts?[BillAccounts.additions]?.accName ?? '',
      ),
      _createRecordRow(
        id: AppConstants.ratio,
        discount: _calculateRatio(billDetails.billDiscountsTotal ?? 0, partialTotal),
        addition: _calculateRatio(billDetails.billAdditionsTotal ?? 0, partialTotal),
      ),
      _createRecordRow(
        id: AppConstants.value,
        discount: discountTotal,
        addition: additionTotal,
      ),
    ];
  }
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
  final double? billWithoutVatTotal;
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
    this.billVatTotal,
    this.billWithoutVatTotal,
    this.billSellerId,
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
    final double? billWithoutVatTotal,
    final double? billGiftsTotal,
    final double? billDiscountsTotal,
    final double? billAdditionsTotal,
  }) =>
      BillDetails(
        billGuid: billGuid ?? this.billGuid,
        billPayType: billPayType ?? this.billPayType,
        billNumber: billNumber ?? this.billNumber,
        billDate: billDate ?? this.billDate,
        note: note ?? this.note,
        billTotal: billTotal ?? this.billTotal,
        billVatTotal: billVatTotal ?? this.billVatTotal,
        billWithoutVatTotal: billWithoutVatTotal ?? this.billWithoutVatTotal,
        billCustomerId: billCustomerId ?? this.billCustomerId,
        billSellerId: billSellerId ?? this.billSellerId,
        billDiscountsTotal: billDiscountsTotal ?? this.billDiscountsTotal,
        billGiftsTotal: billGiftsTotal ?? this.billGiftsTotal,
        billAdditionsTotal: billAdditionsTotal ?? this.billAdditionsTotal,
      );

  factory BillDetails.fromJson(Map<String, dynamic> json) => BillDetails(
        billGuid: json['billGuid'],
        billPayType: json['billPayType'],
        billNumber: json['billNumber'],
        billDate: json['billDate'],
        note: json['note'],
        billCustomerId: json['billCustomerId'],
        billSellerId: json['billSellerId'],
        billTotal: json['billTotal'],
        billVatTotal: json['billVatTotal'],
        billWithoutVatTotal: json['billWithoutVatTotal'],
        billGiftsTotal: json['billGiftsTotal'],
        billDiscountsTotal: json['billDiscountsTotal'],
        billAdditionsTotal: json['billAdditionsTotal'],
      );

  Map<String, dynamic> toJson() => {
        'billGuid': billGuid,
        'billPayType': billPayType,
        'billNumber': billNumber,
        'billDate': billDate,
        'note': note,
        'billCustomerId': billCustomerId,
        'billTotal': billTotal,
        'billWithoutVatTotal': billWithoutVatTotal,
        'billVatTotal': billVatTotal,
        'billSellerId': billSellerId,
        'billGiftsTotal': billGiftsTotal,
        'billDiscountsTotal': billDiscountsTotal,
        'billAdditionsTotal': billAdditionsTotal,
      };
}

class BillItems {
  final List<BillItem> itemList;

  BillItems({required this.itemList});

  BillItems copyWith({List<BillItem>? itemList}) => BillItems(
        itemList: itemList ?? this.itemList,
      );

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
  }) =>
      BillItem(
        itemGuid: itemGuid ?? this.itemGuid,
        itemName: itemName ?? this.itemName,
        itemQuantity: itemQuantity ?? this.itemQuantity,
        itemTotalPrice: itemTotalPrice ?? this.itemTotalPrice,
        itemSubTotalPrice: itemSubTotalPrice ?? this.itemSubTotalPrice,
        itemVatPrice: itemVatPrice ?? this.itemVatPrice,
        itemGiftsNumber: itemGiftsNumber ?? this.itemGiftsNumber,
        itemGiftsPrice: itemGiftsPrice ?? this.itemGiftsPrice,
      );

  factory BillItem.fromJson(Map<String, dynamic> json) => BillItem(
        itemGuid: json['ItemGuid'],
        itemName: json['ItemName'],
        itemQuantity: json['ItemQuantity'],
        itemTotalPrice: json['itemTotalPrice'],
        itemSubTotalPrice: json['itemSubTotalPrice'],
        itemVatPrice: json['itemVatPrice'],
        itemGiftsNumber: json['itemGiftsNumber'],
        itemGiftsPrice: json['itemGiftsPrice'],
      );

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
