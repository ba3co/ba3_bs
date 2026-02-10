import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_layout/body_bond_layout_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/bond_type.dart';

class BondTypeWidget extends StatelessWidget {
  const BondTypeWidget(
      {super.key,
        required this.onTap,
        required this.bondTypeModel,
        required this.bondsController});

  final VoidCallback onTap;
  final BondTypeModel bondTypeModel;
  final AllBondsController bondsController;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        width: 67.w,
        height: 170.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: 0.2,
            color: AppColors.grayColor,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bondTypeModel.value,
                    style: AppTextStyles.headLineStyle2,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Image.asset(
                  bondTypeModel.type.icon,
                  width: 0.035.sw,
                  height: 0.035.sh,
                  color: AppUIUtils.parseColor(bondTypeModel.color),
                ),
              ],
            ),
            Spacer(),

            GestureDetector(
              onTap: () {
                // read<AllBondsController>()
                //     .fetchAllBondByType(bondTypeModel.type, context);
              },
              child: BodyBondLayoutWidget(
                // firstText: "${AppStrings.from.tr}  ${bondTypeModel.from}",
                  firstText: "${AppStrings.number.tr} ${AppStrings.bonds.tr}",
                  secondText:
                  "${bondsController.allBondsCounts(bondTypeModel)}"),
            ),

            // BodyBondLayoutWidget(firstText: "العدد الكلي :", secondText: ((bondType.to-bondType.from)+1).toString()),
            Spacer(),
            AppButton(
              title: AppStrings.newS.tr,
              onPressed: onTap,
              iconData: Icons.add,
              color: AppUIUtils.parseColor(bondTypeModel.color).withAlpha(220),
            )
          ],
        ));
  }
}
