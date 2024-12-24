import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../users_management/controllers/user_management_controller.dart';

AppBar chequesLayoutAppBar() {
  return AppBar(
    title: Column(
      children: [
        const Text('الشيكات', style: TextStyle(fontWeight: FontWeight.w700)),
        Text(
          read<UserManagementController>().loggedInUserModel?.userName ?? '',
          style: const TextStyle(color: Colors.blue, fontSize: 14),
        ),
      ],
    ),
    actions: [
      IconButton(
          onPressed: () {
            read<UserManagementController>().userStatus = UserManagementStatus.first;
            Get.offAllNamed(AppRoutes.loginScreen);
          },
          icon: const Icon(Icons.logout, color: Colors.red))
    ],
  );
}
