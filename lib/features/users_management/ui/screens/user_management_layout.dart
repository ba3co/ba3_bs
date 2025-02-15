
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
              text: '${AppStrings.administration.tr} ${AppStrings.users.tr}',
              onTap: () {
                userManagementController. userNavigator.navigateToAllUsersScreen();
              }),
          if(RoleItemType.administrator.hasReadPermission)
          ...[
          AppMenuItem(
              text: '${AppStrings.administration.tr} ${AppStrings.roles.tr}',
              onTap: () {
                userManagementController. userNavigator.navigateToLAllPermissionsScreen();
              })],
          AppMenuItem(
              text: AppStrings.attendanceRecord.tr,
              onTap: () {
                userManagementController. userNavigator.navigateToUserTimeListScreen();
              }),
        ],
      ),
    );
  }
}
