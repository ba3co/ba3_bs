import 'dart:math' as math;

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/controllers/material_group_controller.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_group.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/material_controller.dart';

void _showMaterialGroupActions(
  BuildContext context,
  MaterialGroupController mgc,
  MaterialGroupModel group,
) {
  final size = MediaQuery.sizeOf(context);
  OverlayService.showDialog(
    context: context,
    title: group.groupName,
    dialogAlignment: Alignment.center,
    width: math.min(400.0, size.width * 0.88),
    height: math.min(280.0, size.height * 0.42),
    content: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, c) {
            return AppButton(
              width: c.maxWidth,
              title: AppStrings.viewGroupChildren.tr,
              iconData: Icons.inventory_2_outlined,
              onPressed: () {
                OverlayService.back();
                read<MaterialController>().navigateToAllMaterialScreen(
                  groupGuid: group.matGroupGuid,
                  context: context,
                );
              },
            );
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            return AppButton(
              width: c.maxWidth,
              title: AppStrings.editMaterialGroup.tr,
              iconData: Icons.edit_outlined,
              color: Colors.green.shade700,
              onPressed: () {
                OverlayService.back();
                mgc.openMaterialGroupEditor(context, existing: group);
              },
            );
          },
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, c) {
            return AppButton(
              width: c.maxWidth,
              title: AppStrings.close.tr,
              color: Colors.grey,
              onPressed: OverlayService.back,
            );
          },
        ),
      ],
    ),
  );
}

class AllMaterialsGroupScreen extends StatelessWidget {
  const AllMaterialsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialGroupController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allGroups.tr,
        isLoading: controller.isLoading,
        tableSourceModels: controller.materialGroups,
        icon: Icons.add,
        onIconPressed: () => controller.openMaterialGroupEditor(context),
        onLoaded: (event) {},
        onSelected: (selectedRow) {
          final groupGuid = selectedRow.row?.cells[AppConstants.materialGroupIdFiled]?.value?.toString();
          if (groupGuid == null || groupGuid.isEmpty) return;
          final g = controller.materialGroups.firstWhereOrNull((e) => e.matGroupGuid == groupGuid);
          if (g == null) return;
          _showMaterialGroupActions(context, controller, g);
        },
      );
    });
  }
}
