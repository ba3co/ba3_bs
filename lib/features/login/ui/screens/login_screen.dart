import 'package:ba3_bs/core/styling/app_colors.dart';
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
    final userManagementController = Get.find<UserManagementController>();
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoginHeaderText(),
          VerticalSpace(),
          Center(
            child: Column(
              spacing: 15,
              children: [
                SizedBox(
                  width: .3.sw,
                  child: TextFormField(
                    decoration: const InputDecoration(
                      label: Text('اسم الحساب'),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    controller: userManagementController.loginNameController,
                  ),
                ),
                SizedBox(
                  width: .3.sw,
                  child: Obx(
                    () => TextFormField(
                      maxLength: 6,
                      obscureText: !userManagementController.isPasswordVisible.value,
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
                        fillColor: Colors.white,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                      ],
                      controller: userManagementController.loginPasswordController,
                    ),
                  ),
                )
              ],
            ),
          ),
          VerticalSpace(20),
          SizedBox(
            width: .3.sw,
            child: ElevatedButton(
              onPressed: () {
                userManagementController.checkUserStatus();
              },
              child: Text('دخول'),
            ),
          )
          // Column(
          //   children: [
          //     const Center(
          //       child: Text(
          //         "ادخل الرقم السري الخاص بك",
          //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          //       ),
          //     ),
          //     const VerticalSpace(30),
          //     SizedBox(
          //       height: 75,
          //       child: GetBuilder<UserManagementController>(
          //         builder: (controller) {
          //           return controller.userStatus != UserManagementStatus.login
          //               ? PinInputFields(controller: controller)
          //               : const LoadingIndicator();
          //         },
          //       ),
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }
}
