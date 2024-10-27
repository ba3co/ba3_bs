import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/widgets/custom_pluto_grid_style_config.dart';

class BillGridWidget extends StatelessWidget {
  final Color rowColor;
  final List<PlutoRow> rows;
  final List<PlutoColumn> columns;

  const BillGridWidget({
    super.key,
    required this.rowColor,
    required this.rows,
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: PlutoGrid(
        configuration: PlutoGridConfiguration(
          shortcut: const PlutoGridShortcut(),
          style: buildGridStyleConfig(evenRowColor: rowColor),
          localeText: const PlutoGridLocaleText.arabic(),
        ),
        columns: columns,
        rows: rows,
      ),
    );
  }
}
