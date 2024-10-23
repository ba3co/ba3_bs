import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_spacer.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../controllers/pattern_controller.dart';

class PartnerRatioCommission extends StatelessWidget {
  const PartnerRatioCommission({
    super.key,
    required this.patternController,
  });

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: ((Get.width * 0.45) / 2) - 5,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text("نسبة الشريك :")),
              Expanded(
                child: CustomTextFieldWithoutIcon(
                  controller: patternController.patPartnerRatio,
                  onSubmitted: (text) async {},
                  onChanged: (_) {
                    patternController.editPatternModel?.patPartnerRatio = double.tryParse(_) ?? 0.0;
                  },
                ),
              ),
            ],
          ),
        ),
        const HorizontalSpace(10),
        SizedBox(
          width: ((Get.width * 0.45) / 2) - 5,
          child: Row(
            children: [
              const SizedBox(width: 100, child: Text("عمولة التحويل :")),
              Expanded(
                child: CustomTextFieldWithoutIcon(
                  controller: patternController.patPartnerCommission,
                  onSubmitted: (text) async {},
                  onChanged: (_) {
                    patternController.editPatternModel?.patPartnerCommission = double.tryParse(_) ?? 0.0;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
