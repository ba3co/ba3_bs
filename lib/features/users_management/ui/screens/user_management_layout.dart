import 'dart:developer';

import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';

class UserManagementLayout extends StatelessWidget {
  const UserManagementLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final UserManagementController userManagementController = read<UserManagementController>();
    log('userModel ${userManagementController.loggedInUserModel?.userName}');
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('الإدارة'),
              ),
              body: Column(
                children: [
                  AppMenuItem(
                      text: 'إدارة المستخدمين',
                      onTap: () {
                        userManagementController.navigateToLAllUsersScreen();
                      }),
                  AppMenuItem(
                      text: 'إدارة الصلاحيات',
                      onTap: () {
                        userManagementController.navigateToLAllPermissionsScreen();
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
