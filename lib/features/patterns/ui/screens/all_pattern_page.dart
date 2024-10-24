import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/new_pluto.dart';
import '../../controllers/pattern_controller.dart';
import 'add_pattern_page.dart';

class AllPatternPage extends StatelessWidget {
  const AllPatternPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PatternController>(
        builder: (controller) => CustomPlutoGridWithAppBar(
              title: "أنماط البيع",
              onLoaded: (e) {},
              isLoading: controller.isLoading,
              onSelected: (p0) {
                Get.to(const AddPatternPage());
              },
            ));
  }
}
