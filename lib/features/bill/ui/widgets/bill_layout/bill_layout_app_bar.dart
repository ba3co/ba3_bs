import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../../../../users_management/controllers/user_management_controller.dart';

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

  );
}
