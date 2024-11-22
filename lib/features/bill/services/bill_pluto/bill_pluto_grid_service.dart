import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../data/models/invoice_record_model.dart';
import 'bill_pluto_utils.dart';

class BillPlutoGridService {
  final IPlutoController controller;

  BillPlutoGridService(this.controller);

  PlutoGridStateManager get mainTableStateManager => controller.mainTableStateManager;

  PlutoGridStateManager get additionsDiscountsStateManager => controller.additionsDiscountsStateManager;

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

  void updateAdditionDiscountCells(double total, BillPlutoUtils invoiceUtils) {
    if (additionsDiscountsStateManager.rows.isEmpty) return;

    for (final row in additionsDiscountsStateManager.rows) {
      // Update both discount and addition cells based on the total value
      final fields = [AppConstants.discount, AppConstants.addition];

      for (final field in fields) {
        total == 0
            ? updateAdditionsDiscountsCellValue(row.cells[field]!, '')
            : _updateCell(field, row, total, invoiceUtils);
      }
    }
  }

  void _updateCell(String field, PlutoRow row, double total, BillPlutoUtils plutoUtils) {
    final ratio = plutoUtils.getCellValueInDouble(row.cells, _getTargetField(field));

    final newValue = ratio == 0 ? '' : controller.calculateAmountFromRatio(ratio, total);

    final valueCell = row.cells[field]!;

    updateAdditionsDiscountsCellValue(valueCell, newValue);
  }

  String _getTargetField(String field) =>
      field == AppConstants.discount ? AppConstants.discountRatio : AppConstants.additionRatio;

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
          AppConstants.discountRatio: PlutoCell(value: record[AppConstants.discountRatio] ?? ''),
          AppConstants.addition: PlutoCell(value: record[AppConstants.addition] ?? ''),
          AppConstants.additionRatio: PlutoCell(value: record[AppConstants.additionRatio] ?? ''),
        };
        return PlutoRow(cells: cells);
      }).toList();
}
