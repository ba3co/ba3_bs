import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'pluto_grid_style_config.dart';

class PlutoWithEdite extends StatelessWidget {
  const PlutoWithEdite({
    super.key,
    this.shortCut,
    this.onChanged,
    this.rowColorCallback,
    required this.onRowSecondaryTap,
    this.evenRowColor = Colors.blueAccent,
    required this.columns,
    required this.rows,
    required this.onLoaded,
  });

  final List<PlutoColumn> columns;
  final List<PlutoRow> rows;
  final PlutoGridShortcut? shortCut;
  final Function(PlutoGridOnChangedEvent)? onChanged;
  final Function(PlutoGridOnRowSecondaryTapEvent) onRowSecondaryTap;
  final void Function(PlutoGridOnLoadedEvent)? onLoaded;
  final PlutoRowColorCallback? rowColorCallback;
  final Color evenRowColor;

  @override
  Widget build(BuildContext context) {
    return PlutoGrid(
      columns: columns,
      rows: rows,
      onRowSecondaryTap: onRowSecondaryTap,
      onChanged: onChanged,
      rowColorCallback: rowColorCallback,
      columnMenuDelegate: PlutoColumnMenuDelegateDefault(),
      configuration: PlutoGridConfiguration(
        shortcut: shortCut ?? const PlutoGridShortcut(),
        style: buildGridStyleConfig(
          evenRowColor: evenRowColor,
        ),
        localeText: Get.locale == Locale('ar', 'AR')
            ? PlutoGridLocaleText.arabic()
            : PlutoGridLocaleText(),
      ),
      onLoaded: onLoaded,
    );
  }
}