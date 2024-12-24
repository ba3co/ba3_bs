
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/bond/ui/widgets/bond_layout/body_bond_layout_Widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/enums/enums.dart';

class BondItemWidget extends StatelessWidget {
  const BondItemWidget({super.key, required this.onTap, required this.bondType});

  final VoidCallback onTap;
  final BondType bondType;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        width: 70.w,
        height: 170.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1,
            color: Colors.cyan,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bondType.value,
                    style: AppTextStyles.headLineStyle2,
                    textDirection: TextDirection.rtl,
                  ),
                ),
                Image.asset(
                  bondType.icon,
                  width: 0.035.sw,
                  height: 0.035.sh,
                  // color: index == tabIndex ? AppColors.whiteColor : AppColors.grayColor,
                ),
              ],
            ),
            Spacer(),

            BodyBondLayoutWidget(firstText: "من  ${bondType.from}", secondText: "الى  ${bondType.to}"),
            // BodyBondLayoutWidget(firstText: "العدد الكلي :", secondText: ((bondType.to-bondType.from)+1).toString()),
            Spacer(),
            AppButton(title: "جديد", onPressed: onTap, iconData: Icons.add)
          ],
        ));
  }
}
