import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../users_management/controllers/user_management_controller.dart';

class MainHeader extends StatelessWidget {
  const MainHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      children: [
        Container(
          height: 0.025.sh,
          width: 0.15.sw,
          alignment: Alignment.center,
          child:  Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                "المستخدم :",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: Colors.black,
                ),
              ),
              Text(
                Get.find<UserManagementController>().userModel?.userName?? "",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blueColor,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(

          onTap: () {
            Get.find<UserManagementController>().userStatus = UserManagementStatus.first;
            Get.offAllNamed(AppRoutes.loginScreen);
          },
          child: Container(
            height: 0.05.sh,
            width: 0.15.sw,
            alignment: Alignment.center,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.blueColor),
            child: const Text(
              "تسجيل الخروج",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.whiteColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
