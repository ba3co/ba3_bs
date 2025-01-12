import 'package:ba3_bs/core/services/firebase/implementations/services/firestore_service.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../../core/services/get_x/shared_preferences_service.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../../users_management/data/datasources/roles_data_source.dart';
import '../../../users_management/data/datasources/users_data_source.dart';
import '../widgets/login_header_text.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: ScaleTransition(
                scale: _animation,
                child: LoginHeaderText(),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        } else {
          _navigateToLogin();
          return Scaffold(
            body: Center(
              child: ScaleTransition(
                scale: _animation,
                child: LoginHeaderText(),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _initializeApp() async {
    final sharedPreferencesService = await putAsync(SharedPreferencesService().init());
    final fireStoreService = FireStoreService();

    final rolesRepo = RemoteDataSourceRepository(RolesDatasource(databaseService: fireStoreService));
    final usersRepo = FilterableDataSourceRepository(UsersDatasource(databaseService: fireStoreService));

    put(
      UserManagementController(rolesRepo, usersRepo, sharedPreferencesService),
      permanent: true,
    );
  }

  void _navigateToLogin() {
    // Delay navigation until after the current frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      read<UserManagementController>().navigateToLogin();
    });
  }
}
