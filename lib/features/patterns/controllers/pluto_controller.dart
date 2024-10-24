import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoController extends GetxController {
  GlobalKey plutoKey = GlobalKey();

  List<PlutoColumn> getColumns(List<dynamic> dataList, {String? type}) {
    log('getColumns ${dataList.map((e) => e.toJson())}');
    List<PlutoColumn> columns = [];
    if (dataList.isEmpty) {
      return columns;
    } else {
      Map<String, dynamic> sampleData = type != null ? dataList.first?.toMap(type: type) : dataList.first?.toMap();
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

  List<PlutoRow> getRows(List<dynamic> modelList, {String? type}) {
    List<PlutoRow> rows = [];
    if (modelList.isEmpty) {
      return rows;
    } else {
      rows = modelList.map((model) {
        Map<String, dynamic> rowData = type != null ? model!.toMap(type: type) : model!.toMap();

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
