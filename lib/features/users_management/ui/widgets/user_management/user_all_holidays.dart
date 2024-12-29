import 'package:ba3_bs/core/widgets/organized_widget.dart';
import 'package:ba3_bs/features/users_management/ui/widgets/user_management/holiday_item_widget.dart';
import 'package:ba3_bs/features/users_management/ui/widgets/user_management/working_hour_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../controllers/user_management_controller.dart';

class UserAllHolidays extends StatelessWidget {
  const UserAllHolidays({super.key, required this.controller});

  final UserManagementController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OrganizedWidget(
        titleWidget: Center(
          child: Text(
            "عطل المستخدم",
            style: AppTextStyles.headLineStyle2,
          ),
        ),
        bodyWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) => HolidayItemWidget(
                holiday: "12-12-2024",

                onDelete: () => controller.deleteWorkingHour(key: index),

              ),
              separatorBuilder: (context, index) => VerticalSpace(),
              itemCount: controller.holidaysLength,
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
                        'اضافة',
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