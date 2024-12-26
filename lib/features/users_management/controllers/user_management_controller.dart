import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/features/users_management/services/role_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../core/services/firebase/implementations/filterable_data_source_repo.dart';
import '../../../core/services/get_x/shared_preferences_service.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';
import '../services/role_form_handler.dart';
import '../services/user_form_handler.dart';

class UserManagementController extends GetxController with AppNavigator {
  final DataSourceRepository<RoleModel> _rolesFirebaseRepo;

  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  final sharedPrefsService = read<SharedPreferencesService>();

  UserManagementController(this._rolesFirebaseRepo, this._usersFirebaseRepo);

  // Services
  late final RoleService _roleService;

  // Form Handlers
  late final UserFormHandler userFormHandler;
  late final RoleFormHandler roleFormHandler;

  // Data
  List<RoleModel> allRoles = [];
  List<UserModel> allUsers = [];

  RoleModel? roleModel;

  UserModel? loggedInUserModel;
  UserModel? selectedUserModel;

  TextEditingController loginPasswordController = TextEditingController();
  TextEditingController loginNameController = TextEditingController();

  final bool isAdmin = true;

  RxBool isPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAllRoles();
    getAllUsers();

    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _roleService = RoleService();
    userFormHandler = UserFormHandler();
    roleFormHandler = RoleFormHandler();
  }

  RoleModel? getRoleById(String id) {
    try {
      return allRoles.firstWhere((role) => role.roleId == id);
    } catch (e) {
      return null;
    }
  }

  // Check if all roles are selected
  bool areAllRolesSelected() =>
      RoleItemType.values.every((type) => roleFormHandler.rolesMap[type]?.length == RoleItem.values.length);

  // Check if all roles are selected for a specific RoleItemType
  bool areAllRolesSelectedForType(RoleItemType type) =>
      roleFormHandler.rolesMap[type]?.length == RoleItem.values.length;

  // Select all roles
  void selectAllRoles() {
    for (final type in RoleItemType.values) {
      roleFormHandler.rolesMap[type] = RoleItem.values.toList();
    }
    update();
  }

  // Deselect all roles
  void deselectAllRoles() {
    roleFormHandler.rolesMap.clear();
    update();
  }

  // Select all roles for a specific RoleItemType
  void selectAllRolesForType(RoleItemType type) {
    roleFormHandler.rolesMap[type] = RoleItem.values.toList();
    update();
  }

  // Deselect all roles for a specific RoleItemType
  void deselectAllRolesForType(RoleItemType type) {
    roleFormHandler.rolesMap[type] = [];
    update();
  }

  // Fetch roles using the repository
  Future<void> getAllRoles() async {
    log('getAllRoles');
    final result = await _rolesFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedRoles) {
        allRoles = fetchedRoles;
      },
    );

    update();
  }

  // Fetch roles using the repository
  Future<void> getAllUsers() async {
    log('getAllUsers');
    final result = await _usersFirebaseRepo.getAll();

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUsers) {
        allUsers = fetchedUsers;
      },
    );

    update();
  }

  // Fetch roles using the repository
  Future<void> getUserById(String userId) async {
    final result = await _usersFirebaseRepo.getById(userId);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUser) => _handelGetUserByIdSuccess(fetchedUser),
    );
  }

  _handelGetUserByIdSuccess(UserModel userModel) {
    loggedInUserModel = userModel;
    offAll(AppRoutes.mainLayout);
  }

  void checkUserStatus() async {
    final loginName = loginNameController.text.trim();
    final loginPassword = loginPasswordController.text.trim();

    if (loginName.isEmpty || loginPassword.isEmpty) {
      AppUIUtils.onFailure('من فضلك قم بادخال اسم الحساب و الرقم السري!');
      return;
    }

    if (loginPassword.length < 6) {
      AppUIUtils.onFailure('من فضلك أدخل كلمة مرور مكونة من 6 أرقام على الأقل!');
      return;
    }

    await _checkUserByPin();
  }

  void _handleGetUserPinSuccess(List<UserModel> fetchedUsers) async {
    if (fetchedUsers.isEmpty) {
      await _handleNoMatch();
      return;
    }

    loggedInUserModel = fetchedUsers.first;

    final isLoginNameMatch = loggedInUserModel?.userName?.trim() == loginNameController.text;
    if (!isLoginNameMatch) {
      AppUIUtils.onFailure('أسم المستخدم غير صحيح!');
      return;
    }
    sharedPrefsService.setString(AppConstants.userIdKey, loggedInUserModel?.userId ?? '');
    offAll(AppRoutes.mainLayout);
  }

  Future<void> _checkUserByPin() async {
    final result =
        await _usersFirebaseRepo.fetchWhere(field: AppConstants.userPassword, value: loginPasswordController.text);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUsers) => _handleGetUserPinSuccess(fetchedUsers),
    );
  }

  void navigateToLogin() async {
    if (sharedPrefsService.getString(AppConstants.userIdKey) == null) {
      offAll(AppRoutes.loginScreen);
    } else {
      getUserById(sharedPrefsService.getString(AppConstants.userIdKey)!);
    }
  }

  void navigateToAddRoleScreen([RoleModel? role]) {
    roleFormHandler.init(role);
    to(AppRoutes.addRoleScreen);
  }

  void navigateToAddUserScreen([UserModel? user]) {
    userFormHandler.init(user);
    to(AppRoutes.addUserScreen);
  }

  void navigateToLAllUsersScreen() => to(AppRoutes.showAllUsersScreen);

  void navigateToLAllPermissionsScreen() => to(AppRoutes.showAllPermissionsScreen);

  Future<void> _handleNoMatch() async {
    if (Get.currentRoute != AppRoutes.loginScreen) {
      navigateToLogin();
    } else {
      AppUIUtils.onFailure('لا يوجد تطابق!');
    }

    loginNameController.clear();
    loginPasswordController.clear();
  }

  Future<void> saveOrUpdateRole({RoleModel? existingRoleModel}) async {
    // Validate the form first
    if (!roleFormHandler.validate()) return;

    // Create the role model from the provided data
    final updatedRoleModel = _roleService.createRoleModel(
      roleModel: existingRoleModel,
      roles: roleFormHandler.rolesMap,
      roleName: roleFormHandler.roleNameController.text,
    );

    // Handle null role model
    if (updatedRoleModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات!');
      return;
    }

    final result = await _rolesFirebaseRepo.save(updatedRoleModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) {
        AppUIUtils.onSuccess('تم الحفظ بنجاح');
        getAllRoles();
      },
    );
  }

  Future<void> saveOrUpdateUser({UserModel? existingUserModel}) async {
    // Validate the form first
    if (!userFormHandler.validate()) return;

    // Create the user model from the provided data
    final updatedUserModel = _roleService.createUserModel(
      userModel: existingUserModel,
      userName: userFormHandler.userNameController.text,
      userPassword: userFormHandler.passController.text,
      userRoleId: userFormHandler.selectedRoleId.value,
      userSellerId: userFormHandler.selectedSellerId.value,
    );

    // Handle null user model
    if (updatedUserModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات و البائع!');
      return;
    }

    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) {
        AppUIUtils.onSuccess('تم الحفظ بنجاح');
        getAllUsers();
      },
    );
  }

  @override
  void onClose() {
    userFormHandler.dispose();
    roleFormHandler.dispose();
    super.onClose();
  }

  void logOut() {
    sharedPrefsService.remove(AppConstants.userIdKey);
    navigateToLogin();
  }
}
