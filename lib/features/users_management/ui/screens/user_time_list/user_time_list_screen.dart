import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class UserTimeListScreen extends StatelessWidget {
  const UserTimeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(
        builder: (userManagementController) {
      return PlutoGridWithAppBar(
        title: AppStrings.allUsers.tr,
        isLoading: userManagementController.isLoading,
        rowHeight: 60,
        tableSourceModels: userManagementController.filteredAllUsersWithNunTime,
        onLoaded: (event) {},
        onSelected: (selectedRow) {
          final userId =
              selectedRow.row?.cells[AppConstants.userIdFiled]?.value;
          userManagementController.userNavigator.navigateToUserDetails(userId);
        },
      );
    });
  }
}
