import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../controllers/entry_bond/entry_bond_controller.dart';

class BondDataGridSource extends DataGridSource {
  BondDataGridSource() {
    // Initialize data rows when creating the data source
    _dataGridRows = Get.find<EntryBondController>().buildBondDataGridRows();
  }

  List<DataGridRow> _dataGridRows = [];

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return Container(
          alignment: Alignment.center,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value == null
                ? ''
                : dataGridCell.value is double
                    ? dataGridCell.value.toStringAsFixed(2)
                    : dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget? buildTableSummaryCellWidget(GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex, String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Text(summaryValue),
    );
  }

  @override
  Future<bool> canSubmitCell(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    return false; // Prevent submission; keep cells editable
  }
}
