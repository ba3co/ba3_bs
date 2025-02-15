import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/materials/controllers/material_group_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class AllMaterialsGroupScreen extends StatelessWidget {
  const AllMaterialsGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialGroupController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: '${AppStrings.all.tr} ${AppStrings.groups.tr}',
        isLoading: controller.isLoading,
        tableSourceModels: controller.materialGroups,
        onLoaded: (event) {},
        onSelected: (selectedRow) {},
      );
    });
  }
}
