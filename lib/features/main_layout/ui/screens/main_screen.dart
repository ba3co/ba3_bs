import 'dart:io';
import 'package:ba3_bs/features/main_layout/controllers/main_controller.dart';
import 'package:ba3_bs/features/main_layout/ui/widgets/right_main_widget.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/styling/app_colors.dart';
import '../../controllers/window_close_controller.dart';
import '../widgets/left_main_widget.dart';
class MainScreen extends StatelessWidget {
  const MainScreen({super.key});
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
      Get.put(WindowCloseController());
    }
    return SafeArea(
      child: GetBuilder<MainController>(builder: (mainController) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            backgroundColor: AppColors.whiteColor,
            body: Row(
              children: [
                RightMainWidget(
                  mainController: mainController,
                ),
                LeftMainWidget(
                  mainController: mainController,
                )
                // Expanded(child:mainController. appLayouts[mainController.tabIndex].layout),
              ],
            ),
          ),
        );
      }),
    );
  }
}
