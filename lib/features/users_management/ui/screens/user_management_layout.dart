import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_menu_item.dart';

class UserManagementLayout extends StatelessWidget {
  const UserManagementLayout({super.key});

  @override
  Widget build(BuildContext context) {
    UserManagementController userManagementController = Get.find<UserManagementController>();
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('الإدارة'),
              ),
              body: !userManagementController.isAdmin
                  ? const Center(
                      child: Text('غير مصرح لك بالدخول'),
                    )
                  : Column(
                      children: [
                        AppMenuItem(
                            text: 'إدارة المستخدمين',
                            onTap: () {
                              userManagementController.navigateToLAllUsersScreen();
                            }),
                        AppMenuItem(
                            text: 'إدارة الصلاحيات',
                            onTap: () {
                              userManagementController
                                ..getAllRoles()
                                ..navigateToLAllPermissionsScreen();
                            }),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
