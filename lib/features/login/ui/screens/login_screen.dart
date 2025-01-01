import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../users_management/controllers/user_management_controller.dart';
import '../widgets/login_header_text.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userManagementController = read<UserManagementController>();
    return Scaffold(
      body: Center(
        child: Container(
          width: 0.8.sw,
          height: 0.8.sh,
          padding: EdgeInsets.all(15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: AppColors.grayColor, blurRadius: 25, spreadRadius: 0.1)],
            color: Colors.white,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(15),
                width: 0.35.sw,
                child: Column(
                  spacing: 15,
                  children: [
                    Spacer(),
                    Text(
                      "تسجيل الدخول",
                      style: AppTextStyles.headLineStyle1,
                    ),
                    SizedBox(
                      width: .25.sw,
                      child: TextFormField(
                        decoration: InputDecoration(
                          label: Text('اسم الحساب'),
                          filled: true,
                          fillColor: AppColors.backGroundColor,
                        ),
                        controller: userManagementController.loginNameController,
                      ),
                    ),
                    SizedBox(
                      width: .25.sw,
                      child: Obx(
                        () => TextFormField(
                          maxLength: 6,
                          obscureText: !userManagementController.isPasswordVisible.value,
                          onFieldSubmitted: (value) {
                            userManagementController.checkUserStatus();
                          },
                          decoration: InputDecoration(
                            label: const Text('كلمة السر'),
                            suffixIcon: IconButton(
                              icon: Icon(
                                userManagementController.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                                size: 20,
                                color: AppColors.blueColor,
                              ),
                              onPressed: () {
                                userManagementController.userFormHandler.updatePasswordVisibility();
                              },
                            ),
                            errorMaxLines: 2,
                            filled: true,
                            fillColor: AppColors.backGroundColor,
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(6),
                          ],
                          controller: userManagementController.loginPasswordController,
                        ),
                      ),
                    ),
                    VerticalSpace(20),
                    InkWell(
                      onTap: () {
                        userManagementController.checkUserStatus();
                      },
                      child: Container(
                        height: 32.h,
                        width: .25.sw,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(5), color: AppColors.blueColor),
                        child: Text(
                          'دخول',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                    Spacer(),
                  ],
                ),
              ),
              VerticalDivider(),
              Expanded(child: const LoginHeaderText()),
            ],
          ),
        ),
      ),
    );
  }
}
