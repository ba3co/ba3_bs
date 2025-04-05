import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';
import '../interfaces/i_tex_selection_handler.dart';

class TaxDropdown extends StatelessWidget {
  const TaxDropdown({super.key, required this.taxSelectionHandler, this.width});

  final ITexSelectionHandler taxSelectionHandler;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return TextAndExpandedChildField(
      label: AppStrings.tax.tr,
      child: Container(
        height: AppConstants.constHeightDropDown,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Obx(() {
          return OverlayService.showDropdown<VatEnums>(
            value: taxSelectionHandler.selectedTax.value,
            items: VatEnums.values,
            onChanged: taxSelectionHandler.onSelectedTaxChanged,
            textStyle: const TextStyle(fontSize: 14),
            itemLabelBuilder: (tax) => tax.taxName!,
            height: AppConstants.constHeightTextField,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black38),
              borderRadius: BorderRadius.circular(5),
            ),
            onCloseCallback: () {},
          );
        }),
      ),
    );
  }
}
