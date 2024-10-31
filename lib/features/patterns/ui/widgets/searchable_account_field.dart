import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../controllers/pattern_controller.dart';

class SearchableAccountField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const SearchableAccountField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.45,
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: CustomTextFieldWithIcon(
              controller: controller,
              onSubmitted: (text) {
                final patternController = Get.find<PatternController>();
                patternController.openAccountSelectionDialog(text, controller);
              },
            ),
          ),
        ],
      ),
    );
  }
}
