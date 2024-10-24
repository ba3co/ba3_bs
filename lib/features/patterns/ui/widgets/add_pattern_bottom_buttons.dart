import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_button.dart';
import '../../controllers/pattern_controller.dart';

class AddPatternBottomButtons extends StatelessWidget {
  const AddPatternBottomButtons({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppButton(
            title: "جديد",
            onPressed: () {
              //      patternController.clearController();
            },
            iconData: Icons.open_in_new_outlined),
        Obx(
          () => AppButton(
            title: "اضافة",
            isLoading: patternController.isLoading.value,
            onPressed: () {
              patternController.addNewPattern();
            },
            iconData: Icons.add,
          ),
        ),
      ],
    );
  }
}
