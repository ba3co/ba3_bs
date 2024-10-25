import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/utils/utils.dart';
import '../data/models/invoice_record_model.dart';

class InvoicePlutoController extends GetxController {
  InvoicePlutoController() {
    getColumns();
  }

  getColumns() {
    Map<PlutoColumn, dynamic> sampleData = InvoiceRecordModel().toEditedMap();
    columns = sampleData.keys.toList();
    update();
    return columns;
  }

  clearRowIndex(int rowIdx) {
    final rowToRemove = stateManager.rows[rowIdx];

    stateManager.removeRows([rowToRemove]);
    Get.back();
    update();
  }

  String typeBile = '';
  String customerName = '';

  getRows(List<InvoiceRecordModel> modelList) {
    stateManager.removeAllRows();
    final newRows = stateManager.getNewRows(count: 30);

    if (modelList.isEmpty) {
      stateManager.appendRows(newRows);
      return rows;
    } else {
      rows = modelList.map((model) {
        Map<PlutoColumn, dynamic> rowData = model.toEditedMap();

        Map<String, PlutoCell> cells = {};

        rowData.forEach((key, value) {
          cells[key.field] = PlutoCell(value: value?.toString() ?? '');
        });

        return PlutoRow(cells: cells);
      }).toList();
    }

    stateManager.appendRows(rows);
    stateManager.appendRows(newRows);
    // print(rows.length);
    return rows;
  }

  List<PlutoRow> rows = [];
  late PlutoGridStateManager stateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());
  List<PlutoColumn> columns = [];

  double computeWithoutVatTotal() {
    int invRecQuantity = 0;
    double subtotals = 0.0;
    double total = 0.0;

    stateManager.setShowLoading(true);
    for (var record in stateManager.rows) {
      if (record.toJson()["invRecQuantity"] != '' &&
          record.toJson()["invRecSubTotal"] != '' &&
          (record.toJson()["invRecGift"] == '' || (int.tryParse(record.toJson()["invRecGift"] ?? "0") ?? 0) >= 0)) {
        invRecQuantity =
            int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecQuantity"].toString())) ?? 0;
        subtotals =
            double.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecSubTotal"].toString())) ?? 0;

        total += invRecQuantity * (subtotals);
      }
    }

    stateManager.setShowLoading(false);
    WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then(
      (value) {
        // update();
      },
    );
    return total;
  }

  int computeGiftsTotal() {
    int total = 0;

    stateManager.setShowLoading(true);
    for (var record in stateManager.rows) {
      if (record.toJson()["invRecGift"] != null && record.toJson()["invRecGift"] != '') {
        total = int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecQuantity"].toString())) ?? 0;
      }
    }
    stateManager.setShowLoading(false);

    return total;
  }

  double computeWithVatTotal() {
    double total = 0.0;
    for (var record in stateManager.rows) {
      if (record.toJson()["invRecQuantity"] != '' && record.toJson()["invRecSubTotal"] != '') {
        total += double.tryParse(record.toJson()["invRecTotal"].toString()) ?? 0;
      }
    }
    stateManager.setShowLoading(false);

    return total;
  }

  void updateCellValue(String field, dynamic value) {
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

    updateCellValue("invRecTotal", total.toStringAsFixed(2));
  }
}
