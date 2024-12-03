import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/pluto/controllers/pluto_controller.dart';

class PlutoGridWithAppBar extends StatelessWidget {
  const PlutoGridWithAppBar({
    super.key,
    required this.onLoaded,
    required this.onSelected,
    this.onRowDoubleTap,
    required this.title,
    this.isLoading = false,
    required this.tableSourceModels,
    this.icon,
    this.onIconPressed,
    this.leadingIcon,
    this.onLeadingIconPressed,
  });

  final Function(PlutoGridOnLoadedEvent) onLoaded;

  final Function(PlutoGridOnRowDoubleTapEvent)? onRowDoubleTap;
  final Function(PlutoGridOnSelectedEvent) onSelected;

  final String title;
  final List<PlutoAdaptable> tableSourceModels;
  final bool isLoading;
  final IconData? icon;
  final VoidCallback? onIconPressed;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingIconPressed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: plutoGridAppBar(icon, onIconPressed),
      body: GetBuilder<PlutoController>(
        builder: (controller) {
          return isLoading
              ? const SizedBox()
              : Column(
                  children: [
                    Expanded(
                      child: PlutoGrid(
                        key: controller.plutoKey,
                        onLoaded: (event) {
                          event.stateManager.setShowColumnFilter(true);
                        },
                        onSelected: onSelected,
                        columns: controller.generateColumns(tableSourceModels),
                        rows: controller.generateRows(tableSourceModels),
                        mode: PlutoGridMode.selectWithOneTap,
                        configuration: PlutoGridConfiguration(
                          shortcut: const PlutoGridShortcut(),
                          style: PlutoGridStyleConfig(
                            enableRowColorAnimation: true,
                            evenRowColor: Colors.blueAccent.withOpacity(0.5),
                            columnTextStyle:
                                const TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                            activatedColor: Colors.white.withOpacity(0.5),
                            cellTextStyle:
                                const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                            gridPopupBorderRadius: const BorderRadius.all(Radius.circular(15)),
                            gridBorderRadius: const BorderRadius.all(Radius.circular(15)),
                            // gridBorderColor: Colors.transparent,
                          ),
                          localeText: const PlutoGridLocaleText.arabic(),
                        ),
                        createFooter: (stateManager) {
                          stateManager.setPageSize(100, notify: false); // default 40

                          return PlutoPagination(stateManager);
                        },
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }

  AppBar plutoGridAppBar(IconData? icon, VoidCallback? onIconPressed) {
    return AppBar(
      centerTitle: true,
      leading: leadingIcon != null
          ? IconButton(
              onPressed: onLeadingIconPressed,
              icon: Icon(leadingIcon),
            )
          : null,
      title: Text(title),
      actions: [
        if (icon != null)
          IconButton(
            onPressed: onIconPressed,
            color: Colors.blue,
            icon: Icon(icon),
          ),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
            child: Text('عدد العناصر المتأثرة: ${tableSourceModels.length}')),
      ],
    );
  }
}
