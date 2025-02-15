import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/pattern_controller.dart';
import 'add_pattern_screen.dart';

class AllPatternScreen extends StatelessWidget {
  const AllPatternScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatternController>(
        builder: (controller) => PlutoGridWithAppBar(
              title: '${ApiConstants.patterns} ${AppStrings.al.tr + AppStrings.sell.tr}',
              isLoading: controller.isLoading,
              tableSourceModels: controller.billsTypes,
              onLoaded: (e) {},
              onSelected: (p0) {
                Get.to(const AddPatternScreen());
              },
            ));
  }
}
