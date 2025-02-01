import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';

import '../../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class UserTimeListScreen extends StatelessWidget {
  const UserTimeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserManagementController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: 'جميع الموظفين',
        isLoading: controller.isLoading,
        tableSourceModels: controller.allUsers,
        onLoaded: (event) {},
        onSelected: (selectedRow) {
        },
      );
    });
  }
}
