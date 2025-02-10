import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/custom_icon_button.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../floating_window/services/overlay_service.dart';
import '../../../controllers/bill/bill_details_controller.dart';

class BillDetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BillDetailsAppBar({
    super.key,
    required this.billDetailsController,
    required this.billSearchController,
    required this.billTypeModel,
  });

  final BillDetailsController billDetailsController;
  final BillSearchController billSearchController;
  final BillTypeModel billTypeModel;

  // kToolbarHeight: default AppBar height.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leadingWidth: 100,
      title: Text('${billTypeModel.fullName}'),
      actions: [
        SizedBox(
          height: AppConstants.constHeightTextField,
          child: Row(
            children: [
              Visibility(
                visible: billTypeModel.billPatternType?.hasCashesAccount ?? true,
                child: SizedBox(
                  width: 250,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 80,
                        child: Text(
                          "نوع الفاتورة" ": ",
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                      Expanded(
                        child: Obx(() {
                          return OverlayService.showDropdown<InvPayType>(
                            value: billDetailsController.selectedPayType.value,
                            items: InvPayType.values,
                            itemLabelBuilder: (type) => type.label,
                            onChanged: (selectedType) {
                              billDetailsController.onPayTypeChanged(selectedType);
                            },
                            textStyle: const TextStyle(fontSize: 14),
                            height: AppConstants.constHeightTextField,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.black38),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            onCloseCallback: () {
                              log('InvPayType Dropdown Overly Closed.');
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  HorizontalSpace(20),
                  CustomIconButton(
                    onPressed: () {
                      billSearchController.tail();
                    },
                    disabled: billSearchController.isTail,
                    icon: FaIcon(
                      FontAwesomeIcons.arrowRotateRight,
                      size: 14,
                    ),
                  ),
                  HorizontalSpace(5),
                  CustomIconButton(
                    disabled: billSearchController.isTail,
                    onPressed: () {
                      billSearchController.jumpForwardByTen();
                    },
                    icon: FaIcon(
                      Icons.keyboard_double_arrow_right_outlined,
                    ),
                  ),
                  CustomIconButton(
                    disabled: billSearchController.isTail,
                    onPressed: () {
                      billSearchController.next();
                    },
                    icon: FaIcon(
                      Icons.keyboard_arrow_right_outlined,
                    ),
                  ),
                  HorizontalSpace(5),
                  SizedBox(
                    width: Get.width * 0.10,
                    child: CustomTextFieldWithoutIcon(
                      isNumeric: true,
                      textEditingController: billDetailsController.billNumberController,
                      onSubmitted: (billNumber) {
                        billSearchController.goToBillByNumber(billNumber.toInt);
                      },
                    ),
                  ),
                  HorizontalSpace(5),
                  CustomIconButton(
                    onPressed: () {
                      billSearchController.previous();
                    },
                    disabled: billSearchController.isHead,
                    icon: FaIcon(
                      Icons.keyboard_arrow_left_outlined,
                    ),
                  ),
                  CustomIconButton(
                    onPressed: () {
                      billSearchController.jumpBackwardByTen();
                    },
                    disabled: billSearchController.isHead,
                    icon: FaIcon(
                      Icons.keyboard_double_arrow_left,
                    ),
                  ),
                  HorizontalSpace(5),
                  CustomIconButton(
                    onPressed: () {
                      billSearchController.head();
                    },
                    disabled: billSearchController.isHead,
                    icon: FaIcon(
                      FontAwesomeIcons.arrowRotateLeft,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const HorizontalSpace(20),
      ],
    );
  }
}
