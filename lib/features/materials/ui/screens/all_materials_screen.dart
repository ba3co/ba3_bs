import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/new_pluto.dart';
import '../../controllers/material_controller.dart';

class AllMaterialsScreen extends StatelessWidget {
  const AllMaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MaterialController>(builder: (controller) {
      return CustomPlutoGridWithAppBar(
        title: "جميع المواد",
        isLoading: controller.isLoading,
        tableSourceModels: controller.materials,
        onLoaded: (event) {},
        onSelected: (cell) {},
      );
    });
  }
}
