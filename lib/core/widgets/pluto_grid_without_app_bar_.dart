import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/widgets/pluto_grid_style_config.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/pluto/controllers/pluto_controller.dart';

class PlutoGridWithoutAppBar<T> extends StatelessWidget {
  const PlutoGridWithoutAppBar({
    super.key,
    required this.onLoaded,
    required this.onSelected,
    this.onRowDoubleTap,
    this.title,
    this.isLoading = false,
    required this.tableSourceModels,
    this.icon,
    this.onIconPressed,
    this.leadingIcon,
    this.onLeadingIconPressed,
    this.type,
    this.bottomChild,
    this.onRowSecondaryTap,
    this.rowHeight,
    this.rightChild,
  });

  final Function(PlutoGridOnLoadedEvent) onLoaded;
  final Function(PlutoGridOnRowDoubleTapEvent)? onRowDoubleTap;
  final Function(PlutoGridOnSelectedEvent) onSelected;

  final String? title;
  final List<PlutoAdaptable> tableSourceModels;
  final bool isLoading;
  final IconData? icon;
  final VoidCallback? onIconPressed;
  final IconData? leadingIcon;
  final VoidCallback? onLeadingIconPressed;
  final T? type;
  final Widget? bottomChild;
  final Widget? rightChild;
  final double? rowHeight;
  final Function(PlutoGridOnRowSecondaryTapEvent)? onRowSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlutoController>(
      builder: (controller) {
        return PlutoGrid(
          key: controller.plutoKey,
          onLoaded: (event) {
            event.stateManager.activateColumnsAutoSize();

            // event.stateManager.setShowColumnFilter(true);
            event.stateManager.appendNewRows(count: 30);
            onLoaded(event);
          },
          onRowSecondaryTap: onRowSecondaryTap,
          onSelected: onSelected,
          onRowDoubleTap: onRowDoubleTap,
          rowColorCallback: (rowColorContext) {
            if (rowColorContext.row.cells['isFreeTax']?.value == AppConstants.taxFreeAccountName.replaceAll('ضريبة القيمة المضافة', '')) {
              return Colors.red.shade100;
            } else {
              return rowColorContext.rowIdx % 2 == 0 ? Colors.white : Colors.blue.shade200;
            }
          },
          columns: controller.generateColumns<T>(tableSourceModels, type),
          rows: controller.generateRows<T>(tableSourceModels, type),
          mode: PlutoGridMode.readOnly,
          configuration: PlutoGridConfiguration(
            style: buildGridStyleConfig(
              evenRowColor: Colors.blue.shade200,
            ),

            localeText: Get.locale == Locale('ar', 'AR') ? PlutoGridLocaleText.arabic() : PlutoGridLocaleText(),
          ),
        );
      },
    );
  }
}