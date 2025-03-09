import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AllAttendanceScreen extends StatelessWidget {
  const AllAttendanceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
  return  GetBuilder<UserManagementController>(builder: (userManagementController) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 1.sw,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: userManagementController.filteredUsersWithDetails.map((user) {
              return Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.backGroundColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5),
                  ],
                ),
                height: 70.h,
                width: 40.w,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Text(user.userName!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    if (user.loginDelay == AppStrings.notLoggedToday.tr && user.logoutDelay == AppStrings.notLoggedToday.tr)
                      Expanded(child: Text(AppStrings.notLoggedToday.tr, style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)))
                    else ...[
                      Expanded(child: Text("${AppStrings.delayedEntry.tr}: ${user.loginDelay ?? AppStrings.nothing.tr}")),
                      Expanded(child: Text("${AppStrings.leaveEarly.tr}: ${user.logoutDelay ?? AppStrings.nothing.tr}")),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }
}