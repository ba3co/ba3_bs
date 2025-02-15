import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/users_management/controllers/user_details_controller.dart';
import 'package:ba3_bs/features/users_management/ui/widgets/user_management/holiday_item_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';

class UserAllHolidays extends StatelessWidget {
  const UserAllHolidays({super.key, required this.controller});

  final UserDetailsController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
          child: Text(
            "${AppStrings.holidays.tr} ${AppStrings.user.tr}",
            style: AppTextStyles.headLineStyle2,
          ),
        ),
        bodyWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 1.sw,
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => HolidayItemWidget(
                  holiday: controller.holidays.elementAt(index),
                  onDelete: () => controller.deleteHoliday( element: controller.holidays.elementAt(index)),
                ),
                separatorBuilder: (context, index) => HorizontalSpace(),
                itemCount: controller.holidaysLength,
              ),
            ),
            SizedBox(
              width: 80,
              // alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    controller.addHoliday();
                  },
                  icon: Row(
                    children: [
                      Icon(
                        Icons.add,
                        size: 12,
                        color: AppColors.blueColor,
                      ),
                      HorizontalSpace(),
                      Text(
                        AppStrings.add
                        .tr,
                        style: AppTextStyles.headLineStyle4.copyWith(fontSize: 12, color: AppColors.blueColor),
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
