import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../controllers/pattern_controller.dart';

class PatternTypeDropdown extends StatelessWidget {
  const PatternTypeDropdown({
    super.key,
    required this.patternController,
  });

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.45,
      child: Row(
        children: [
          SizedBox(width: 100, child: Text('${AppStrings.type} ${AppStrings.al + AppStrings.bill}')),
          Container(
              width: (Get.width * 0.45) - 100,
              height: AppConstants.constHeightTextField,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
              ),
              child: DropdownButton(
                hint: Text('${AppStrings.choose} ${AppStrings.type} ${AppStrings.al + AppStrings.pattern}'),
                dropdownColor: Colors.white,
                focusColor: Colors.white,
                alignment: Alignment.center,
                underline: const SizedBox(),
                isExpanded: true,
                value: patternController.patternFormHandler.selectedBillPatternType,
                items: BillPatternType.values.map((BillPatternType type) {
                  return DropdownMenuItem<BillPatternType>(
                    value: type,
                    child: Center(
                      child: Text(type.label, textDirection: TextDirection.rtl),
                    ),
                  );
                }).toList(),
                onChanged: patternController.patternFormHandler.onSelectedTypeChanged,
              )),
        ],
      ),
    );
  }
}
