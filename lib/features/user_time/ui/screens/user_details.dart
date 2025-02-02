import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/user_time/ui/widgets/user_details_widgets/all_holidays_widget.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/user_details_widgets/time_widget.dart';
import '../widgets/user_time_details_widgets/user_daily_time_widget.dart';

class UserDetails extends StatelessWidget {
  const UserDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final userModel = read<UserManagementController>().selectedUserModel!;
    return Scaffold(
      appBar: AppBar(
        title: Text(userModel.userName!),
        centerTitle: true,
      ),
      body: GetBuilder<UserManagementController>(builder: (userManagementController) {
        return ListView(
          children: [
            TimeWidget(
              userManagementController: userManagementController,
            ),
            AllHolidaysWidget(
              userManagementController: userManagementController,
            ),
            UserDailyTimeWidget(
              userModel:userModel,
            ),
          ],
        );
      }),
    );
  }
}
