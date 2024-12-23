import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../users_management/controllers/user_management_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    _checkUserStatus();

    return const Scaffold(
      body: Center(
        child: Text("يتم تسجيل الدخول"), // "Logging in" in Arabic
      ),
    );
  }

  void _checkUserStatus() {
    Get.find<UserManagementController>().navigateToLogin(true);
  }
}
