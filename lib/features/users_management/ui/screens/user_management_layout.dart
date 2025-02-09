
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_menu_item.dart';
import '../../data/models/role_model.dart';

class UserManagementLayout extends StatelessWidget {
  const UserManagementLayout({super.key});

  @override
  Widget build(BuildContext context) {
    final UserManagementController userManagementController = read<UserManagementController>();
    return Scaffold(

      body: Column(
        children: [
          AppMenuItem(
              text: 'إدارة المستخدمين',
              onTap: () {
                userManagementController. userNavigator.navigateToAllUsersScreen();
              }),
          if(RoleItemType.administrator.hasReadPermission)
          ...[
          AppMenuItem(
              text: 'إدارة الصلاحيات',
              onTap: () {
                userManagementController. userNavigator.navigateToLAllPermissionsScreen();
              })],
          AppMenuItem(
              text: 'سجل الدوام',
              onTap: () {
                userManagementController. userNavigator.navigateToUserTimeListScreen();
              }),
        ],
      ),
    );
  }
}
