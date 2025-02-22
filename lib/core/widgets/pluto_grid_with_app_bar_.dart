import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/pluto/controllers/pluto_controller.dart';

class PlutoGridWithAppBar<T> extends StatelessWidget {
  const PlutoGridWithAppBar({
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
    this.child,
    this.appBar,
    this.onRowSecondaryTap,
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
  final Widget? child;
  final AppBar? appBar;
  final Function(PlutoGridOnRowSecondaryTapEvent)? onRowSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? _buildAppBar(),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildGrid(context),
    );
  }

  Widget _buildGrid(BuildContext context) {
    return GetBuilder<PlutoController>(
      builder: (controller) {
        return Column(
          children: [
            Expanded(

              child: PlutoGrid(
                key: controller.plutoKey,
                onLoaded: (event) {
                  event.stateManager.setShowColumnFilter(true);
                  onLoaded(event);
                },

                onRowSecondaryTap: onRowSecondaryTap,
                onSelected: onSelected,
                onRowDoubleTap: onRowDoubleTap,
                columns: controller.generateColumns<T>(tableSourceModels, type),
                rows: controller.generateRows<T>(tableSourceModels, type),
                mode: PlutoGridMode.selectWithOneTap,
                configuration: PlutoGridConfiguration(
                  style: PlutoGridStyleConfig(
                    evenRowColor: Colors.blueAccent.withAlpha(127),
                    // cellTextStyle: TextStyle(fontFamily: 'Almarai'),
                    // columnTextStyle: TextStyle(fontFamily: 'Almarai'),
                    activatedBorderColor: Colors.teal
                  ),

                  localeText: Get.locale == Locale('ar', 'AR') ? PlutoGridLocaleText.arabic() : PlutoGridLocaleText(),
                ),
                createFooter: (stateManager) {
                  stateManager.setPageSize(100, notify: false);
                  return PlutoPagination(stateManager);
                },
              ),
            ),
            if (child != null) child!,
          ],
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      centerTitle: true,
      leading: leadingIcon != null
          ? IconButton(
              onPressed: onLeadingIconPressed,
              icon: Icon(leadingIcon),
            )
          : null,
      title: Text(title ?? AppStrings.dataTable.tr),
      actions: [
        if (icon != null)
          IconButton(
            onPressed: onIconPressed,
            color: Colors.blue,
            icon: Icon(icon),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
          child: Text('${AppStrings.numberOfAffectedItems.tr}: ${tableSourceModels.length}'),
        ),
      ],
    );
  }
}