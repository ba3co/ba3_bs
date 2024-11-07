import 'package:ba3_bs/core/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:pluto_grid/pluto_grid.dart';

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
    invRecId = map['invRecId'];
    invRecProduct = map['invRecProduct'];
    invRecQuantity = int.tryParse(map['invRecQuantity'].toString());
    invRecSubTotal = double.tryParse(map['invRecSubTotal'].toString());
    invRecTotal = double.tryParse(map['invRecTotal'].toString());
    invRecVat = double.tryParse((map['invRecVat']).toString());
    invRecIsLocal = map['invRecIsLocal'];
    invRecGift = int.tryParse(map['invRecGift'].toString());
    invRecGiftTotal = (map['invRecGiftTotal'] ?? 0) * 1.0;
  }

  toJson() {
    return {
      'invRecId': invRecId,
      'invRecProduct': invRecProduct,
      'invRecQuantity': invRecQuantity,
      'invRecSubTotal': invRecSubTotal,
      'invRecTotal': invRecTotal,
      'invRecVat': invRecVat,
      'invRecIsLocal': invRecIsLocal,
      'invRecGift': invRecGift,
      'invRecGiftTotal': invRecGiftTotal,
    };
  }

  InvoiceRecordModel.fromJsonPluto(String matId, Map<dynamic, dynamic> map) {
    String? prodName = map['invRecProduct'];
    int? giftsNumber = _parseInteger(map['invRecGift']);
    int? quantity = _parseInteger(map['invRecQuantity']);
    double? subTotal = _parseDouble(map['invRecSubTotal']);
    double? total = _parseDouble(map['invRecTotal']);
    double? vat = _parseDouble(map['invRecVat']);

    invRecId = matId;
    invRecProduct = prodName;
    invRecQuantity = quantity;
    invRecSubTotal = subTotal;
    invRecTotal = total;
    invRecVat = vat;
    invRecIsLocal = map['invRecIsLocal'];
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
    return int.tryParse(Utils.replaceArabicNumbersWithEnglish(value.toString()));
  }

// Helper method to parse doubles, handling Arabic numerals
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(Utils.replaceArabicNumbersWithEnglish(value.toString()));
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
        field: 'invRecId',
        readOnly: true,
        width: 50,
        type: PlutoColumnType.text(),
        renderer: (rendererContext) {
          if (rendererContext.row.cells["invRecProduct"]?.value != '') {
            rendererContext.cell.value = rendererContext.rowIdx.toString();
            return Text(rendererContext.rowIdx.toString());
          }
          return const Text("");
        },
      ): invRecId,
      PlutoColumn(
        title: 'المادة',
        field: 'invRecProduct',
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return false;
        },
      ): invRecProduct,
      PlutoColumn(
        title: 'الكمية',
        field: 'invRecQuantity',
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells['invRecProduct']?.value == '';
        },
      ): invRecQuantity,
      PlutoColumn(
        title: 'السعر الإفرادي',
        field: "invRecSubTotal",
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells['invRecProduct']?.value == '';
        },
      ): invRecSubTotal,
      PlutoColumn(
        title: 'الضريبة',
        field: 'invRecVat',
        type: PlutoColumnType.text(),
      ): invRecVat,
      PlutoColumn(
        title: 'المجموع',
        field: 'invRecTotal',
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells['invRecProduct']?.value == '';
        },
      ): invRecTotal,
      PlutoColumn(
        title: 'الهدايا',
        field: "invRecGift",
        type: PlutoColumnType.text(),
        checkReadOnly: (row, cell) {
          return cell.row.cells['invRecProduct']?.value == '';
        },
      ): invRecGift,
    };
  }
}
