import 'package:ba3_bs/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../data/models/bill_type_model.dart';

class PatternRecordDataSource extends DataGridSource {
  List<DataGridRow> dataGridRows = [];
  dynamic newCellValue;
  TextEditingController editingController = TextEditingController();

  PatternRecordDataSource({required Map<String, BillTypeModel> billTypeRecords}) {
    dataGridRows.clear();
    dataGridRows = billTypeRecords.values
        .map<DataGridRow>((billType) => DataGridRow(cells: [
              DataGridCell<String>(columnName: "patId", value: billType.id),
              DataGridCell<String>(columnName: AppConstants.patCode, value: billType.id),
              //  DataGridCell<String>(columnName: Const.patPrimary, value: getAccountNameFromId(e.patPrimary)),
              DataGridCell<String>(columnName: AppConstants.patName, value: billType.id),
              DataGridCell<String>(columnName: AppConstants.patType, value: Utils.getInvTypeFromEnum(billType.id!)),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    Color getRowBackgroundColor() {
      final int index = effectiveRows.indexOf(row);
      if (index % 2 == 0) {
        return Colors.white;
      }

      return Colors.blue.withOpacity(0.5);
    }

    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
          alignment: Alignment.center,
          color: getRowBackgroundColor(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            dataGridCell.value == null ? '' : dataGridCell.value.toString(),
            overflow: TextOverflow.ellipsis,
          ));
    }).toList());
  }

  @override
  Widget? buildTableSummaryCellWidget(GridTableSummaryRow summaryRow, GridSummaryColumn? summaryColumn,
      RowColumnIndex rowColumnIndex, String summaryValue) {
    return Container(
      padding: const EdgeInsets.all(15.0),
      child: Text(summaryValue),
    );
  }

  // description
  @override
  Future<bool> canSubmitCell(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
    // Return false, to retain in edit mode.
    return false; // or super.canSubmitCell(dataGridRow, rowColumnIndex, column);
  }
}
