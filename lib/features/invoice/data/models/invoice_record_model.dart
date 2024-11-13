import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_service_utils.dart';
import 'bill_model.dart';

class InvoiceRecordModel {
  String? invRecId;
  String? invRecProduct;
  String? prodChoosePriceMethod;
  int? invRecQuantity;
  int? invRecGift;
  double? invRecSubTotal;
  double? invRecTotal;
  double? invRecVat;
  double? invRecGiftTotal;
  bool? invRecIsLocal;

  InvoiceRecordModel({
    this.invRecId,
    this.invRecProduct,
    this.invRecQuantity,
    this.invRecSubTotal,
    this.invRecTotal,
    this.invRecVat,
    this.prodChoosePriceMethod,
    this.invRecIsLocal,
    this.invRecGift,
    this.invRecGiftTotal,
  });

  /// Factory method to create an InvoiceRecordModel from a BillItem.
  factory InvoiceRecordModel.fromBillItem(BillItem billItem) => InvoiceRecordModel(
        invRecId: billItem.itemGuid,
        invRecProduct: billItem.itemName,
        invRecQuantity: billItem.itemQuantity,
        invRecSubTotal: billItem.itemSubTotalPrice,
        invRecTotal: double.tryParse(billItem.itemTotalPrice),
        invRecVat: billItem.itemVatPrice,
        invRecGift: billItem.itemGiftsNumber,
        invRecGiftTotal: billItem.itemGiftsPrice,
      );

  InvoiceRecordModel.fromJson(Map<dynamic, dynamic> map) {
    invRecId = map[AppConstants.invRecId];
    invRecProduct = map[AppConstants.invRecProduct];
    invRecQuantity = int.tryParse(map[AppConstants.invRecQuantity].toString());
    invRecSubTotal = double.tryParse(map[AppConstants.invRecSubTotal].toString());
    invRecTotal = double.tryParse(map[AppConstants.invRecTotal].toString());
    invRecVat = double.tryParse((map[AppConstants.invRecVat]).toString());
    invRecIsLocal = map[AppConstants.invRecIsLocal];
    invRecGift = int.tryParse(map[AppConstants.invRecGift].toString());
    invRecGiftTotal = (map[AppConstants.invRecGiftTotal] ?? 0) * 1.0;
  }

  toJson() {
    return {
      AppConstants.invRecId: invRecId,
      AppConstants.invRecProduct: invRecProduct,
      AppConstants.invRecQuantity: invRecQuantity,
      AppConstants.invRecSubTotal: invRecSubTotal,
      AppConstants.invRecTotal: invRecTotal,
      AppConstants.invRecVat: invRecVat,
      AppConstants.invRecIsLocal: invRecIsLocal,
      AppConstants.invRecGift: invRecGift,
      AppConstants.invRecGiftTotal: invRecGiftTotal,
    };
  }

  InvoiceRecordModel.fromJsonPluto(String matId, Map<dynamic, dynamic> map) {
    String? prodName = map[AppConstants.invRecProduct];
    int? giftsNumber = _parseInteger(map[AppConstants.invRecGift]);
    int? quantity = _parseInteger(map[AppConstants.invRecQuantity]);
    double? subTotal = _parseDouble(map[AppConstants.invRecSubTotal]);
    double? total = _parseDouble(map[AppConstants.invRecTotal]);
    double? vat = _parseDouble(map[AppConstants.invRecVat]);

    invRecId = matId;
    invRecProduct = prodName;
    invRecQuantity = quantity;
    invRecSubTotal = subTotal;
    invRecTotal = total;
    invRecVat = vat;
    invRecIsLocal = map[AppConstants.invRecIsLocal];
    invRecGift = giftsNumber;

    final effectiveVat = vat ?? 0;
    final effectiveSubTotal = subTotal ?? 0;

    if (giftsNumber == null) {
      invRecGiftTotal = null;
    } else {
      invRecGiftTotal = giftsNumber * (effectiveVat + effectiveSubTotal);
    }
  }

// Helper method to parse integers, handling Arabic numerals
  int? _parseInteger(dynamic value) {
    if (value == null) return null;
    return int.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(value.toString()));
  }

// Helper method to parse doubles, handling Arabic numerals
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(value.toString()));
  }

  @override
  int get hashCode => invRecId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceRecordModel && runtimeType == other.runtimeType && invRecId == other.invRecId;

  Map<String, Map<String, dynamic>> getChanges(InvoiceRecordModel other) {
    Map<String, dynamic> newChanges = {};
    Map<String, dynamic> oldChanges = {};

    if (invRecProduct != other.invRecProduct) {
      newChanges['invRecProduct'] = other.invRecProduct;
      oldChanges['invRecProduct'] = invRecProduct;
    }

    if (invRecQuantity != other.invRecQuantity) {
      newChanges['invRecQuantity'] = other.invRecQuantity;
      oldChanges['invRecQuantity'] = invRecQuantity;
    }

    if (invRecSubTotal != other.invRecSubTotal) {
      newChanges['invRecSubTotal'] = other.invRecSubTotal;
      oldChanges['invRecSubTotal'] = invRecSubTotal;
    }

    if (invRecTotal != other.invRecTotal) {
      newChanges['invRecTotal'] = other.invRecTotal;
      oldChanges['invRecTotal'] = invRecTotal;
    }

    if (invRecVat != other.invRecVat) {
      newChanges['invRecVat'] = other.invRecVat;
      oldChanges['invRecVat'] = invRecVat;
    }

    if (invRecIsLocal != other.invRecIsLocal) {
      newChanges['invRecIsLocal'] = other.invRecIsLocal;
      oldChanges['invRecIsLocal'] = invRecIsLocal;
    }
    if (invRecGift != other.invRecGift) {
      newChanges['invRecGift'] = other.invRecGift;
      oldChanges['invRecGift'] = invRecGift;
    }
    if (invRecGiftTotal != other.invRecGiftTotal) {
      newChanges['invRecGiftTotal'] = other.invRecGiftTotal;
      oldChanges['invRecGiftTotal'] = invRecGiftTotal;
    }

    if (newChanges.isNotEmpty) newChanges['invRecId'] = other.invRecId;
    if (oldChanges.isNotEmpty) oldChanges['invRecId'] = invRecId;

    return {"newData": newChanges, "oldData": oldChanges};
  }

  Map<PlutoColumn, dynamic> toEditedMap() {
    return {
      PlutoColumn(
        title: 'الرقم',
        field: AppConstants.invRecId,
        readOnly: true,
        width: 50,
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          if (rendererContext.row.cells[AppConstants.invRecProduct]?.value != '') {
            rendererContext.cell.value = rendererContext.rowIdx.toString();
            return Text(rendererContext.rowIdx.toString());
          }
          return const Text("");
        },
      ): invRecId,
      PlutoColumn(
        title: 'المادة',
        field: AppConstants.invRecProduct,
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return false;
        },
      ): invRecProduct,
      PlutoColumn(
        title: 'الكمية',
        field: AppConstants.invRecQuantity,
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells[AppConstants.invRecProduct]?.value == '';
        },
      ): invRecQuantity,
      PlutoColumn(
        title: 'السعر الإفرادي',
        field: AppConstants.invRecSubTotal,
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells[AppConstants.invRecProduct]?.value == '';
        },
      ): invRecSubTotal,
      PlutoColumn(
        title: 'الضريبة',
        field: AppConstants.invRecVat,
        type: PlutoColumnType.text(),
      ): invRecVat,
      PlutoColumn(
        title: 'المجموع',
        field: AppConstants.invRecTotal,
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells[AppConstants.invRecProduct]?.value == '';
        },
      ): invRecTotal,
      PlutoColumn(
        title: 'الهدايا',
        field: AppConstants.invRecGift,
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells[AppConstants.invRecProduct]?.value == '';
        },
      ): invRecGift,
    };
  }
}
