import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_menu_item.dart';
import '../../../login/controllers/user_management_controller.dart';
import 'add_pattern_page.dart';
import 'all_pattern_page.dart';

class PatternLayout extends StatelessWidget {
  const PatternLayout({super.key});

  @override
  Widget build(BuildContext context) {
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
                //   Get.find<PatternController>().initPattern();
                Get.to(() => const AddPatternPage());
              },
            ),
            AppMenuItem(
              text: "معاينة الانماط",
              onTap: () {
                hasPermissionForOperation(AppConstants.roleUserRead, AppConstants.roleViewPattern).then((value) {
                  if (value) Get.to(() => const AllPatternPage());
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
