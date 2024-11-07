import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../controllers/invoice_pluto_controller.dart';
import '../data/models/invoice_record_model.dart';

class InvoiceGridService {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  PlutoGridStateManager get mainTableStateManager => invoicePlutoController.mainTableStateManager;

  PlutoGridStateManager get additionsDiscountsStateManager => invoicePlutoController.additionsDiscountsStateManager;

  PlutoGridOnChangedEvent? get billAdditionsOnChangedEvent => invoicePlutoController.billAdditionsOnChangedEvent;

  void updateCellValue(PlutoGridStateManager stateManager, String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
      force: true,
    );
  }

  void updateInvoiceValuesByQuantity(int quantity, subtotal, double vat) {
    double total = (subtotal + vat) * quantity;

    updateCellValue(mainTableStateManager, "invRecTotal", total.toStringAsFixed(2));
  }

  void updateInvoiceValues(double subTotal, int quantity) {
    double vat = subTotal * 0.05;
    double total = (subTotal + vat) * quantity;

    updateCellValue(mainTableStateManager, "invRecVat", vat.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, "invRecSubTotal", subTotal.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, "invRecTotal", total.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, "invRecQuantity", quantity);
  }

  void updateInvoiceValuesByTotal(double total, int quantity) {
    double subTotal = total / (quantity * 1.05);
    double vat = subTotal * 0.05;

    updateCellValue(mainTableStateManager, "invRecVat", vat.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, "invRecSubTotal", subTotal.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, "invRecTotal", total.toStringAsFixed(2));
  }

  void updateDiscountCell(double total) {
    String? discountRatioStr = billAdditionsOnChangedEvent!.row.cells['discountRatioId']?.value;
    if (discountRatioStr == null || discountRatioStr.isEmpty) {
      return;
    }
    double discountAmount = invoicePlutoController.calculateDiscountAmount(discountRatioStr, total);

    updateCellValue(additionsDiscountsStateManager, "discountId", discountAmount.toStringAsFixed(2));

    debugPrint('onAdditionsDiscountsChanged on updateDiscountCell');
  }

  void updateAdditionCell(double total) {
    String? additionRatioStr = billAdditionsOnChangedEvent!.row.cells['additionRatioId']?.value;
    if (additionRatioStr == null || additionRatioStr.isEmpty) {
      return;
    }
    double additionAmount = invoicePlutoController.calculateAdditionAmount(
        billAdditionsOnChangedEvent!.row.cells['additionRatioId']?.value, total);

    updateCellValue(additionsDiscountsStateManager, "additionId", additionAmount.toStringAsFixed(2));

    debugPrint('onAdditionsDiscountsChanged on updateAdditionCell');
  }

  List<PlutoRow> convertRecordsToRows(List<InvoiceRecordModel> records) => records.map((record) {
        final rowData = record.toEditedMap();
        final cells = rowData.map((key, value) => MapEntry(key.field, PlutoCell(value: value?.toString() ?? '')));
        return PlutoRow(cells: cells);
      }).toList();

  List<PlutoRow> convertAdditionsDiscountsRecordsToRows(List<Map<String, String>> additionsDiscountsRecords) =>
      additionsDiscountsRecords.map((record) {
        final cells = {
          'accountId': PlutoCell(value: record['accountId'] ?? ''),
          'discountId': PlutoCell(value: record['discountId'] ?? ''),
          'discountRatioId': PlutoCell(value: record['discountRatioId'] ?? ''),
          'additionId': PlutoCell(value: record['additionId'] ?? ''),
          'additionRatioId': PlutoCell(value: record['additionRatioId'] ?? ''),
        };
        return PlutoRow(cells: cells);
      }).toList();

  List<PlutoRow> loadAdditionsDiscountsRows(List<Map<String, String>> additionsDiscountsRecords) {
    additionsDiscountsStateManager.removeAllRows();

    if (additionsDiscountsRecords.isEmpty) {
      return invoicePlutoController.additionsDiscountsRows;
    } else {
      return additionsDiscountsRecords.map((record) {
        final cells = {
          'accountId': PlutoCell(value: record['accountId'] ?? ''),
          'discountId': PlutoCell(value: record['discountId'] ?? ''),
          'discountRatioId': PlutoCell(value: record['discountRatioId'] ?? ''),
          'additionId': PlutoCell(value: record['additionId'] ?? ''),
          'additionRatioId': PlutoCell(value: record['additionRatioId'] ?? ''),
        };
        return PlutoRow(cells: cells);
      }).toList();
    }
  }
}
