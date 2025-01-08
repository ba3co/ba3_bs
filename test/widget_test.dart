import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import 'package:ba3_bs/core/services/get_x/shared_preferences_service.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';

// Mock Classes

class MockDataSourceRepository<T> extends Mock implements DataSourceRepository<T> {}

class MockFilterableDataSourceRepository<T> extends Mock implements FilterableDataSourceRepository<T> {}

void main() {
  late UserManagementController userManagementController;
  late MockDataSourceRepository<RoleModel> mockRolesRepo;
  late MockFilterableDataSourceRepository<UserModel> mockUsersRepo;

  setUp(() async {
    // Mock the dependencies
    mockRolesRepo = MockDataSourceRepository<RoleModel>();
    mockUsersRepo = MockFilterableDataSourceRepository<UserModel>();

    // Provide mock implementations for methods
    when(() => mockRolesRepo.getAll()).thenAnswer((_) async => Right([RoleModel(roleId: 'roleId1', roles: {})]));
    when(() => mockUsersRepo.getAll()).thenAnswer((_) async => Right([]));

    var sharedPreferencesService = await Get.putAsync(() => SharedPreferencesService().init());
    // Initialize the controller with mocked dependencies
    userManagementController = UserManagementController(mockRolesRepo, mockUsersRepo, sharedPreferencesService);

    // Register the controller
    Get.put(userManagementController);
  });

  tearDown(() {
    Get.reset(); // Clean up GetX instance after each test
  });

  test('hasPermission returns true for valid RoleItemType with userAdmin permission', () {
    // Arrange
    final roleModel = RoleModel(
      roleId: 'roleId1',
      roles: {
        RoleItemType.viewBill: [RoleItem.userAdmin],
      },
    );
    final userModel = UserModel(
      userId: 'userId1',
      userName: 'testUser',
      userRoleId: 'roleId1',
    );

    userManagementController.allRoles = [roleModel];
    userManagementController.loggedInUserModel = userModel;

    // Act
    final hasPermission = RoleItemType.viewBill.hasAdminPermission;

    // Assert
    expect(hasPermission, isTrue);
  });

  test('hasPermission returns false if RoleItemType does not have userAdmin permission', () {
    // Arrange
    final roleModel = RoleModel(
      roleId: 'roleId1',
      roles: {
        RoleItemType.viewBill: [
          RoleItem.userRead,
          RoleItem.userUpdate,
          RoleItem.userWrite,
          RoleItem.userDelete,
        ],
      },
    );
    final userModel = UserModel(
      userId: 'userId1',
      userName: 'testUser',
      userRoleId: 'roleId1',
    );

    userManagementController.allRoles = [roleModel];
    userManagementController.loggedInUserModel = userModel;

    // Act
    final hasPermission = RoleItemType.viewBill.hasAdminPermission;

    // Assert
    expect(hasPermission, isFalse);
  });
}
