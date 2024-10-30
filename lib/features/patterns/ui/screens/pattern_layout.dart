import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/features/patterns/controllers/pattern_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/controllers/window_close_controller.dart';
import '../../../../core/widgets/app_menu_item.dart';

class PatternLayout extends StatelessWidget {
  const PatternLayout({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WindowCloseController());
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("أنماط البيع"),
        ),
        body: Column(
          children: [
            AppMenuItem(
              text: "إضافة نمط",
              onTap: () {
                Get.toNamed(AppRoutes.addPatternsScreen);
              },
            ),
            AppMenuItem(
              text: "معاينة الانماط",
              onTap: () {
                Get.find<PatternController>().getAllBillTypes();
                Get.toNamed(AppRoutes.showAllPatternsScreen);
              },
            ),
          ],
        ),
      ),
    );
  }
}
