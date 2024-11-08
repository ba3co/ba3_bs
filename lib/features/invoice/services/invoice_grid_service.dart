import 'dart:developer';

import 'package:ba3_bs/features/invoice/services/invoice_utils.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../controllers/invoice_pluto_controller.dart';
import '../data/models/invoice_record_model.dart';

class InvoiceGridService {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  PlutoGridStateManager get mainTableStateManager => invoicePlutoController.mainTableStateManager;

  PlutoGridStateManager get additionsDiscountsStateManager => invoicePlutoController.additionsDiscountsStateManager;

  InvoiceUtils get invoiceUtils => invoicePlutoController.invoiceUtils;

  void updateCellValue(PlutoGridStateManager stateManager, String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
      force: true,
    );
  }

  void updateAdditionsDiscountsCellValue(PlutoCell cell, dynamic value) {
    additionsDiscountsStateManager.changeCellValue(
      cell,
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

  void updateAdditionDiscountCells(double total) {
    if (total == 0) return;
    _updateCellValue('discount', total);
    _updateCellValue('addition', total);
  }

  void _updateCellValue(String field, double total) {
    final ratioRow = additionsDiscountsStateManager.rows.first;
    final valueRow = additionsDiscountsStateManager.rows.last;

    // Retrieve the ratio value for the specified field.
    final ratio = invoiceUtils.getCellValueInDouble(ratioRow.cells, field);
    if (ratio == 0) return;

    // Calculate the new amount based on the ratio and total.
    final newValue = invoicePlutoController.calculateAmountFromRatio(ratio, total).toStringAsFixed(2);

    // Get the cell to update.
    final valueCell = valueRow.cells[field]!;
    updateAdditionsDiscountsCellValue(valueCell, newValue);

    log('$field amount updated: $newValue');
  }

  List<PlutoRow> convertRecordsToRows(List<InvoiceRecordModel> records) => records.map((record) {
        final rowData = record.toEditedMap();
        final cells = rowData.map((key, value) => MapEntry(key.field, PlutoCell(value: value?.toString() ?? '')));
        return PlutoRow(cells: cells);
      }).toList();

  List<PlutoRow> convertAdditionsDiscountsRecordsToRows(List<Map<String, String>> additionsDiscountsRecords) =>
      additionsDiscountsRecords.map((record) {
        final cells = {
          'id': PlutoCell(value: record['id'] ?? ''),
          'discount': PlutoCell(value: record['discount'] ?? ''),
          'addition': PlutoCell(value: record['addition'] ?? '')
        };
        return PlutoRow(cells: cells);
      }).toList();
}
