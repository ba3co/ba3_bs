import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/services/export_excl/excel_export.dart';

class PlutoController extends GetxController {
  UniqueKey plutoKey = UniqueKey();

  late PlutoGridStateManager stateManager;

  /// Updates the `plutoKey` to a new unique value.
  void updatePlutoKey() {
    plutoKey = UniqueKey();
  }

  /// Generates a list of PlutoColumns based on the first model in the provided list.
  List<PlutoColumn> generateColumns<T>(List<PlutoAdaptable> adaptableModels,
      [T? type]) {
    if (adaptableModels.isEmpty) return [];

    final firstModelData = adaptableModels.first.toPlutoGridFormat(type);

    return firstModelData.keys
        .toList(); // Extracts PlutoColumn objects directly
  }

  /// Generates a list of PlutoRows by mapping each model to its respective cells.
  List<PlutoRow> generateRows<T>(List<PlutoAdaptable> adaptableModels,
      [T? type]) {
    if (adaptableModels.isEmpty) return [];

    updatePlutoKey();
    return adaptableModels.map(_mapModelToRow).toList();
  }

  /// Converts a PlutoAdaptable model to a PlutoRow.
  static PlutoRow _mapModelToRow(PlutoAdaptable model) {
    final cells = model.toPlutoGridFormat().map<String, PlutoCell>(
          (key, value) =>
              MapEntry(key.field, PlutoCell(value: value?.toString() ?? '')),
        );
    return PlutoRow(cells: cells);
  }
  void exportRowsToExcel(ExportFilterOption option) {
    final rows = stateManager.rows;

    final filteredRows = rows.where((row) {
      final value = row.cells['extra_notes']?.value?.toString();
      switch (option) {
        case ExportFilterOption.checked:
          return value == 'true';
        case ExportFilterOption.unchecked:
          return value != 'true';
        case ExportFilterOption.all:
          return true;
      }
    });

    final jsonList = filteredRows.map((row) {
      return row.cells.map((key, cell) => MapEntry(key, cell.value));
    }).toList();

    exportJsonToExcel(jsonList);
  }

}