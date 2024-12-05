import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class PlutoController extends GetxController {
  GlobalKey plutoKey = GlobalKey();

  /// Generates a list of PlutoColumns based on the first model in the provided list.
  List<PlutoColumn> generateColumns(List<PlutoAdaptable> adaptableModels) {
    if (adaptableModels.isEmpty) return [];

    final firstModelData = adaptableModels.first.toPlutoGridFormat();
    return firstModelData.keys.toList();
  }

  /// Generates a list of PlutoRows by mapping each model to its respective cells.
  List<PlutoRow> generateRows(List<PlutoAdaptable> adaptableModels) {
    if (adaptableModels.isEmpty) return [];
    plutoKey = GlobalKey();
    return adaptableModels.map(_mapModelToRow).toList();
  }

  /// Converts a PlutoAdaptable model to a PlutoRow.
  PlutoRow _mapModelToRow(PlutoAdaptable model) {
    final cells = model.toPlutoGridFormat().map<String, PlutoCell>((key, value) {
      return MapEntry(key.title, PlutoCell(value: value?.toString() ?? ''));
    });
    return PlutoRow(cells: cells);
  }
}
