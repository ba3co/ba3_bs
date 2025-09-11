import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../widgets/login_logo_widget.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    _navigateToLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder(
    //   future: _initializeApp(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return Scaffold(body: Center(child: LoginLogoWidget()));
    //     } else if (snapshot.hasError) {
    //       return Scaffold(
    //           body: Center(child: Text("Error: ${snapshot.error}")));
    //     } else {
    //       _navigateToLogin();
    //       return Scaffold(body: Center(child: LoginLogoWidget()));
    //     }
    //   },
    // );

    return Scaffold(body: Center(child: LoginLogoWidget()));
  }

  // Future<void> _initializeApp() async {
  void _navigateToLogin() {
    // Delay navigation until after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      read<UserManagementController>().userNavigator.navigateToLogin();
    });
  }
}
