import 'package:ba3_bs/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ba3_bs/core/services/get_x/shared_preferences_service.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';

// Mock Dependencies
class MockRemoteDataSourceRepository<T> extends Mock
    implements RemoteDataSourceRepository<T> {}

class MockFilterableDataSourceRepository<T> extends Mock
    implements FilterableDataSourceRepository<T> {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserManagementController userManagementController;
  late MockFirebaseFirestore mockFirestore;
  late MockRemoteDataSourceRepository<RoleModel> mockRolesRepo;
  late MockFilterableDataSourceRepository<UserModel> mockUsersRepo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});

    mockFirestore = MockFirebaseFirestore();
    mockRolesRepo = MockRemoteDataSourceRepository<RoleModel>();
    mockUsersRepo = MockFilterableDataSourceRepository<UserModel>();

    when(() => mockRolesRepo.getAll()).thenAnswer(
        (_) async => Right([RoleModel(roleId: 'roleId1', roles: {})]));
    when(() => mockUsersRepo.getAll()).thenAnswer((_) async => Right([]));

    var sharedPreferencesService =
        await Get.putAsync(() => SharedPreferencesService().init());

    // Register mock Firestore in GetX
    Get.put<FirebaseFirestore>(mockFirestore);

    userManagementController = UserManagementController(
      mockRolesRepo,
      mockUsersRepo,
      sharedPreferencesService,
    );

    Get.put(userManagementController);
  });

  tearDown(() {
    Get.reset();
  });

  test('Sample test without Firestore', () {
    expect(1 + 1, equals(2)); // Simple test to verify setup
  });
}
