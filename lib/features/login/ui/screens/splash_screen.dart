import 'package:ba3_bs/core/services/firebase/implementations/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../../core/services/get_x/shared_preferences_service.dart';
import '../../../../core/services/local_database/implementations/services/hive_database_service.dart';
import '../../../../core/services/local_database/interfaces/i_local_database_service.dart';
import '../../../users_management/controllers/user_management_controller.dart';
import '../../../users_management/data/datasources/roles_data_source.dart';
import '../../../users_management/data/datasources/users_data_source.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text("Error: ${snapshot.error}"),
            ),
          );
        } else {
          // Delay navigation until after the current frame
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToLogin();
          });
          return const Scaffold(
            body: Center(child: Text('Redirecting...')),
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

  Future<ILocalDatabaseService<T>> _initializeHiveService<T>({required String boxName}) async {
    Box<T> box = await Hive.openBox<T>(boxName);
    return HiveDatabaseService(box);
  }

  void _navigateToLogin() {
    try {
      read<UserManagementController>().navigateToLogin();
    } catch (e) {
      debugPrint("Error navigating to login: $e");
    }
  }
}
