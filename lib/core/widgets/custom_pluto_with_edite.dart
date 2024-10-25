import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import 'custom_pluto_grid_style_config.dart';

class CustomPlutoWithEdite extends StatelessWidget {
  const CustomPlutoWithEdite({
    super.key,
    required this.controller,
    this.shortCut,
    this.onChanged,
    required this.onRowSecondaryTap,
    this.evenRowColor = Colors.blueAccent,
  });

  final dynamic controller;
  final PlutoGridShortcut? shortCut;
  final Function(PlutoGridOnChangedEvent)? onChanged;
  final Function(PlutoGridOnRowSecondaryTapEvent) onRowSecondaryTap;
  final Color evenRowColor;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: PlutoGrid(
        columns: controller.columns,
        rows: controller.rows,
        onRowSecondaryTap: onRowSecondaryTap,
        onChanged: onChanged,
        configuration: PlutoGridConfiguration(
          shortcut: shortCut ?? const PlutoGridShortcut(),
          style: buildGridStyleConfig(evenRowColor: evenRowColor),
          localeText: const PlutoGridLocaleText.arabic(),
        ),
        onLoaded: (PlutoGridOnLoadedEvent event) {
          controller.stateManager = event.stateManager;
          final newRows = controller.stateManager.getNewRows(count: 30);
          controller.stateManager.appendRows(newRows);

          if (controller.stateManager.rows.isNotEmpty && controller.stateManager.rows.first.cells.length > 1) {
            final secondCell = controller.stateManager.rows.first.cells.entries.elementAt(1).label;
            controller.stateManager.setCurrentCell(secondCell, 0);

            FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
          }
        },
      ),
    );
  }
}
