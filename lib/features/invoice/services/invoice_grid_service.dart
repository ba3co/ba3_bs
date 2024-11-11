import 'dart:developer';

import 'package:ba3_bs/features/invoice/services/invoice_utils.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/constants/app_constants.dart';
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

    updateCellValue(mainTableStateManager, AppConstants.invRecTotal, total.toStringAsFixed(2));
  }

  void updateInvoiceValues(double subTotal, int quantity) {
    double vat = subTotal * 0.05;
    double total = (subTotal + vat) * quantity;

    updateCellValue(mainTableStateManager, AppConstants.invRecVat, vat.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, AppConstants.invRecSubTotal, subTotal.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, AppConstants.invRecTotal, total.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, AppConstants.invRecQuantity, quantity);
  }

  void updateInvoiceValuesByTotal(double total, int quantity) {
    double subTotal = total / (quantity * 1.05);
    double vat = subTotal * 0.05;

    updateCellValue(mainTableStateManager, AppConstants.invRecVat, vat.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, AppConstants.invRecSubTotal, subTotal.toStringAsFixed(2));
    updateCellValue(mainTableStateManager, AppConstants.invRecTotal, total.toStringAsFixed(2));
  }

  void updateAdditionDiscountCells(double total) {
    if (additionsDiscountsStateManager.rows.isEmpty) return;

    final PlutoRow valueRow = invoiceUtils.valueRow;

    // Update both discount and addition cells based on the total value
    final fields = [AppConstants.discount, AppConstants.addition];

    for (final field in fields) {
      total == 0 ? updateAdditionsDiscountsCellValue(valueRow.cells[field]!, '') : _updateCell(field, valueRow, total);
    }
  }

  void _updateCell(String field, PlutoRow valueRow, double total) {
    final PlutoRow ratioRow = invoiceUtils.ratioRow;

    final ratio = invoiceUtils.getCellValueInDouble(ratioRow.cells, field);

    final newValue = ratio == 0 ? '' : invoicePlutoController.calculateAmountFromRatio(ratio, total).toStringAsFixed(2);

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
          AppConstants.id: PlutoCell(value: record[AppConstants.id] ?? ''),
          AppConstants.discount: PlutoCell(value: record[AppConstants.discount] ?? ''),
          AppConstants.addition: PlutoCell(value: record[AppConstants.addition] ?? '')
        };
        return PlutoRow(cells: cells);
      }).toList();
}
