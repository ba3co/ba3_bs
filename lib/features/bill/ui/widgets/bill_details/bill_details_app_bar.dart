import 'dart:developer';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_pattern_type_extension.dart';
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
import '../../../../../core/widgets/language_switch_fa_icon.dart';
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
      automaticallyImplyLeading: false,
      actions: [
        Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 15),
            height: AppConstants.constHeightTextField,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Visibility(
                  visible: billTypeModel.billPatternType?.hasCashesAccount ?? true,
                  child: SizedBox(
                    width: 250,
                    child: Row(
                      spacing: 10,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 70,
                          child: Text(
                            AppStrings.billType.tr,
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                        Expanded(
                          child: Obx(() {
                            return OverlayService.showDropdown<InvPayType>(
                              value: billDetailsController.selectedPayType.value,
                              items: InvPayType.values,
                              itemLabelBuilder: (type) => type.label.tr,
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
                    CustomIconButton(
                      onPressed: () {
                        billSearchController.tail();
                      },
                      disabled: billSearchController.isTail,
                      icon: LanguageSwitchFaIcon(
                        iconData: FontAwesomeIcons.arrowRotateRight,
                        size: 14,
                      ),
                    ),
                    HorizontalSpace(5),
                    CustomIconButton(
                      disabled: billSearchController.isTail,
                      onPressed: () {
                        billSearchController.jumpForwardByTen();
                      },
                      icon: LanguageSwitchFaIcon(
                        iconData: Icons.keyboard_double_arrow_right_outlined,
                      ),
                    ),
                    CustomIconButton(
                      disabled: billSearchController.isTail,
                      onPressed: () {
                        billSearchController.next();
                      },
                      icon: LanguageSwitchFaIcon(
                        iconData: Icons.keyboard_arrow_right_outlined,
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
                      icon: LanguageSwitchFaIcon(
                        iconData: Icons.keyboard_arrow_left_outlined,
                      ),
                    ),
                    CustomIconButton(
                      onPressed: () {
                        billSearchController.jumpBackwardByTen();
                      },
                      disabled: billSearchController.isHead,
                      icon: LanguageSwitchFaIcon(
                        iconData: Icons.keyboard_double_arrow_left,
                      ),
                    ),
                    HorizontalSpace(5),
                    CustomIconButton(
                      onPressed: () {
                        billSearchController.head();
                      },
                      disabled: billSearchController.isHead,
                      icon: LanguageSwitchFaIcon(
                        iconData: FontAwesomeIcons.arrowRotateLeft,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
