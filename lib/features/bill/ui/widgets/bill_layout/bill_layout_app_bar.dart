import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../login/controllers/user_management_controller.dart';

AppBar billLayoutAppBar() {
  return AppBar(
    title: Column(
      children: [
        const Text("الفواتير", style: TextStyle(fontWeight: FontWeight.w700)),
        Text(
          Get.find<UserManagementController>().myUserModel?.userName ?? "",
          style: const TextStyle(color: Colors.blue, fontSize: 14),
        ),
      ],
    ),
    actions: [
      IconButton(
          onPressed: () {
            Get.find<UserManagementController>().userStatus = UserManagementStatus.first;
            Get.offAllNamed(AppRoutes.loginScreen);
          },
          icon: const Icon(Icons.logout, color: Colors.red))
    ],
  );
}
