import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoController extends GetxController {
  GlobalKey plutoKey = GlobalKey();

  List<PlutoColumn> getColumns(List<BillTypeModel> billsTypes) {
    List<PlutoColumn> columns = [];
    if (billsTypes.isEmpty) {
      return columns;
    } else {
      Map<String, dynamic> sampleData = billsTypes.first.toJson();
      columns = sampleData.keys.map((key) {
        return PlutoColumn(
          title: key,
          field: key,
          type: PlutoColumnType.text(),
          enableAutoEditing: false,
          enableColumnDrag: false,
          enableEditingMode: false,
          hide: sampleData.keys.first == key,
        );
      }).toList();
    }

    return columns;
  }

  List<PlutoRow> rows = [];

  List<PlutoRow> getRows(List<BillTypeModel> billsTypes) {
    List<PlutoRow> rows = [];
    if (billsTypes.isEmpty) {
      return rows;
    } else {
      rows = billsTypes.map((billType) {
        Map<String, dynamic> rowData = billType.toJson();

        Map<String, PlutoCell> cells = {};

        rowData.forEach((key, value) {
          cells[key] = PlutoCell(value: value?.toString() ?? '');
        });

        return PlutoRow(cells: cells);
      }).toList();
      plutoKey = GlobalKey();
    }
    return rows;
  }

/* generateColumnsAndRows(List<dynamic> modelList) {
    columns = [];
    rows = [];
    if (modelList.isEmpty) return;
    Map<String, dynamic> sampleData = modelList.first?.toMap();
    columns = sampleData.keys.map((key) {
      return PlutoColumn(
        title: key,
        field: key,
        type: PlutoColumnType.text(),
        enableAutoEditing: false,
        enableColumnDrag: false,
        enableEditingMode: false,
        hide: sampleData.keys.first == key,
      );
    }).toList();
    // إنشاء الصفوف
    rows = modelList.map((model) {
      Map<String, dynamic> rowData = model!.toMap();
      Map<String, PlutoCell> cells = {};

      rowData.forEach((key, value) {
        cells[key] = PlutoCell(value: value?.toString() ?? '');
      });

      return PlutoRow(cells: cells);
    }).toList();
    plutoKey = GlobalKey();
    update();
  }*/
}
