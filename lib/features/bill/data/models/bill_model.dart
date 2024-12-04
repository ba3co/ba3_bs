import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import 'bill_details.dart';
import 'bill_items.dart';
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

  factory BillModel.fromJson(Map<String, dynamic> json) => BillModel(
        billId: json['billId'],
        billTypeModel: BillTypeModel.fromJson(json['billTypeModel']),
        billDetails: BillDetails.fromJson(json['billDetails']),
        items: BillItems.fromJson(json['items']),
      );

  factory BillModel.fromInvoiceData({
    BillModel? billModel,
    String? note,
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
    required List<InvoiceRecordModel> billRecordsItems,
  }) {
    final billDetails = BillDetails.fromInvoiceData(
      existingDetails: billModel?.billDetails,
      note: note,
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

    final items = BillItems.fromInvoiceRecords(billRecordsItems);

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

  factory BillModel.fromImportedJsonFile(Map<String, dynamic> billData) => BillModel(
        billDetails: BillDetails(
          billGuid: billData['B']['BillGuid'],
          billPayType: billData['B']['BillPayType'],
          billNumber: billData['B']['BillNumber'],
          billDate: billData['B']['BillDate'],
          billCustomerId: billData['B']['BillCustPtr'],
          note: billData['B']['Note'],
        ),
        billTypeModel: BillTypeModel(
          billTypeLabel: _billTypeLabel(billData['B']['BillTypeGuid']),
          accounts: {
            BillAccounts.caches: AccountModel(
              id: billData['B']['BillCustPtr'],
              accName: billData['B']['BillCustName'],
            ),
            BillAccounts.store: AccountModel(id: billData['B']['BillStoreGuid']),
          },
        ),
        items: BillItems(
          itemList: (billData['Items']['I'] as List<dynamic>)
              .map((item) => BillItem(
                    itemGuid: item['MatPtr'],
                    itemQuantity: (item['QtyBonus'].split(',').first as String).toInt ?? 0,
                    itemTotalPrice: item['PriceDescExtra'].split(',').first,
                    itemName: item['Note'],
                    itemVatPrice: AppServiceUtils.calcVat(
                      item['VatRatio'],
                      (item['PriceDescExtra'].split(',').first as String).toDouble,
                    ),
                  ))
              .toList(),
        ),
      );

  Map<String, dynamic> toJson() => {
        'billId': billId,
        'billTypeModel': billTypeModel.toJson(),
        'billDetails': billDetails.toJson(),
        'items': items.toJson(),
      };

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

  @override
  Map<String, dynamic> toPlutoGridFormat() => {
        'billId': billId ?? '',
        'رقم الفاتورة': billDetails.billNumber ?? '',
        'التاريخ': billDetails.billDate ?? '',
        'مجموع الضريبة': AppServiceUtils.toFixedDouble(billDetails.billVatTotal),
        'المجموع قبل الضريبة': AppServiceUtils.toFixedDouble(billDetails.billBeforeVatTotal),
        'المجموع الكلي': AppServiceUtils.toFixedDouble(billDetails.billTotal),
        'مجموع الحسم': AppServiceUtils.toFixedDouble(billDetails.billDiscountsTotal),
        'مجموع الاضافات': AppServiceUtils.toFixedDouble(billDetails.billAdditionsTotal),
        'مجموع الهدايا': billDetails.billGiftsTotal ?? 0,
        'نوع الفاتورة': BillType.byLabel(billTypeModel.billTypeLabel ?? "").value,
        'نوع الدفع': InvPayType.fromIndex(billDetails.billPayType ?? 0).label,
        'حساب العميل': billTypeModel.accounts?[BillAccounts.caches]?.accName ?? '',
        'حساب البائع': Get.find<SellerController>().getSellerNameById(billDetails.billSellerId),
        'المستودع': billTypeModel.accounts?[BillAccounts.store] ?? '',
        'وصف': billDetails.note ?? '',
      };

  List<Map<String, String>> get getAdditionsDiscountsRecords {
    final discountTotal = (billDetails.billDiscountsTotal ?? 0);
    final additionTotal = (billDetails.billAdditionsTotal ?? 0);

    if (discountTotal == 0 && additionTotal == 0) {
      return [];
    } else {
      return _additionsDiscountsRecords;
    }
  }

  List<Map<String, String>> get _additionsDiscountsRecords {
    final partialTotal = _partialTotal;
    final discountTotal = (billDetails.billDiscountsTotal ?? 0).toStringAsFixed(2);
    final additionTotal = (billDetails.billAdditionsTotal ?? 0).toStringAsFixed(2);

    return [
      _createRecordRow(
        account: billTypeModel.accounts?[BillAccounts.discounts]?.accName ?? '',
        discountValue: discountTotal,
        discountRatio: _calculateRatio(billDetails.billDiscountsTotal ?? 0, partialTotal),
        additionValue: '',
        additionRatio: '',
      ),
      _createRecordRow(
        account: billTypeModel.accounts?[BillAccounts.additions]?.accName ?? '',
        discountValue: '',
        discountRatio: '',
        additionValue: additionTotal,
        additionRatio: _calculateRatio(billDetails.billAdditionsTotal ?? 0, partialTotal),
      ),
    ];
  }

  static String _billTypeLabel(String typeGuide) => BillType.byTypeGuide(typeGuide).label;

  Map<String, String> _createRecordRow({
    required String account,
    required String discountValue,
    required String additionValue,
    required String discountRatio,
    required String additionRatio,
  }) =>
      {
        AppConstants.id: account,
        AppConstants.discount: discountValue,
        AppConstants.discountRatio: discountRatio,
        AppConstants.addition: additionValue,
        AppConstants.additionRatio: additionRatio,
      };

  String _calculateRatio(double value, double total) => total > 0 ? ((value / total) * 100).toStringAsFixed(0) : '0';

  double get _partialTotal => (billDetails.billVatTotal ?? 0) + (billDetails.billBeforeVatTotal ?? 0);
}
