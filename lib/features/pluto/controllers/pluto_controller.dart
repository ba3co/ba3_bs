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

  void exportRowsToExcel(
      ExportFilterOption option, {
        List<String>? columnsToExport,
      }) {
    final rows = stateManager.rows;

    // Determine which columns to export
    final fieldsToExport = columnsToExport ??
        stateManager.columns.map((c) => c.field).toList();

    // Filter rows based on the option (assuming 'extra_notes' is the checkbox field)
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

    final jsonList = <Map<String, dynamic>>[];

    // Create an empty map template
    final emptyMap = <String, dynamic>{};
    for (final field in fieldsToExport) {
      if (field == '_isNested') continue;
      emptyMap[field] = '';
    }

    for (final row in filteredRows) {
      // Check for nested indicator
      final nestedTitle = row.cells['_isNested']?.value?.toString();

      if (nestedTitle != null) {
        // Find the nested column by title
        final nestedCol = stateManager.columns
            .firstWhereOrNull((c) => c.title == nestedTitle);

        if (nestedCol != null) {
          final nestedField = nestedCol.field;
          final nestedVal = row.cells[nestedField]?.value;

          List<String> items = [];
          if (nestedVal is List) {
            items = nestedVal.map((e) => e.toString().replaceAll('(', '').replaceAll(')', '').trim()).toList();
          } else if (nestedVal != null) {
            String valStr = nestedVal.toString();
            if (valStr.startsWith('[') && valStr.endsWith(']')) {
              valStr = valStr.substring(1, valStr.length - 1);
            }
            items = valStr.split(',').map((s) => s.replaceAll('(', '').replaceAll(')', '').trim()).toList();
          }

          // Create main row map (all fields except _isNested)
          final mainMap = <String, dynamic>{};
          for (final field in fieldsToExport) {
            if (field == '_isNested') continue;
            final cellValue = row.cells[field]?.value;
            mainMap[field] = (field == nestedField)
                ? (items.isNotEmpty ? items.first : '')
                : cellValue;
          }
          jsonList.add(mainMap);

          // Create sub-rows for remaining items
          for (final item in items.skip(1)) {
            final subMap = <String, dynamic>{};
            for (final field in fieldsToExport) {
              if (field == '_isNested') continue;
              subMap[field] = (field == nestedField) ? item : '';
            }
            jsonList.add(subMap);
          }

          jsonList.add(Map.from(emptyMap)); // Add empty row after bill
          continue; // Skip adding the default map
        }
      }

      // Default behavior for non-nested rows (exclude _isNested if present)
      final defaultMap = Map.fromEntries(
        row.cells.entries
            .where((e) =>
        fieldsToExport.contains(e.key) && e.key != '_isNested')
            .map((e) => MapEntry(e.key, e.value.value)),
      );
      jsonList.add(defaultMap);
      jsonList.add(Map.from(emptyMap)); // Add empty row after bill
    }

    exportJsonToExcel(jsonList);
  }


}