import 'dart:developer';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../controllers/bonds/bond_type_controller.dart';


class BondTypeDropdown extends StatelessWidget {
  const BondTypeDropdown({super.key, required this.bondController});

  final BondTypeController  bondController;

  @override
  Widget build(BuildContext context) {
    return TextAndExpandedChildField(
      label: AppStrings.type.tr,
      child: Obx(() {
        return OverlayService.showDropdown<BondType>(
          value: bondController
              .bondTypeFormHandler.selectedBondType.value ??
              BondType.values.first,
          items: BondType.values,
          onChanged: bondController.bondTypeFormHandler.onTypeChanged,
          itemLabelBuilder: (type) => type.label.tr,
          textStyle: const TextStyle(fontSize: 14),
          height: AppConstants.constHeightDropDown,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black38),
            borderRadius: BorderRadius.circular(5),
          ),
          onCloseCallback: () {
            log('BillPatternType Dropdown Overlay Closed.');
          },
        );
      }),
    );
  }
}
