import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/features/users_management/services/role_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../core/services/firebase/implementations/filterable_data_source_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../login/data/repositories/user_repo.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';
import '../services/role_form_handler.dart';
import '../services/user_form_handler.dart';

class UserManagementController extends GetxController with AppNavigator {
  final UserManagementRepository _userRepository;

  final DataSourceRepository<RoleModel> _rolesFirebaseRepo;

  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  UserManagementController(this._userRepository, this._rolesFirebaseRepo, this._usersFirebaseRepo);

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
  UserManagementStatus? userStatus;

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

    if (userStatus == UserManagementStatus.login) return;

    loggedInUserModel = fetchedUsers.first;

    final isLoginNameMatch = loggedInUserModel?.userName?.trim() == loginNameController.text;
    if (!isLoginNameMatch) {
      AppUIUtils.onFailure('أسم المستخدم غير صحيح!');
      return;
    }
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

  void navigateToLogin([bool waitUntilFirstFrameRasterized = false]) {
    if (waitUntilFirstFrameRasterized) {
      WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((_) {
        userStatus = UserManagementStatus.first;

        offAll(AppRoutes.loginScreen);
      });
    } else {
      userStatus = UserManagementStatus.first;
      offAll(AppRoutes.loginScreen);
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
    userStatus = null; // Setting userStatus to null in case of no match
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

  Future<void> saveOrUpdateUser() async {
    // Validate the form first
    if (!userFormHandler.validate()) return;

    // Create the user model from the provided data
    final updatedUserModel = _roleService.createUserModel(
      userModel: selectedUserModel,
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

  void startTimeReport({required String userId, DateTime? customDate}) async {
    final result = await _userRepository.startTimeReport(userId, customDate: customDate);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "Time report start successfully!"),
    );
  }

  void sendTimeReport({required String userId, int? customTime}) async {
    final result = await _userRepository.sendTimeReport(userId, customTime: customTime);
    result.fold(
      (failure) => Get.snackbar("Error", failure.message),
      (success) => Get.snackbar("Success", "Time report sent successfully!"),
    );
  }

  // Log login time
  Future<void> logInTime() async {
    if (loggedInUserModel != null) {
      final result = await _userRepository.logLoginTime(loggedInUserModel!.userId);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Login time logged successfully!"),
      );
    }
  }

  // Log logout time
  Future<void> logOutTime() async {
    if (loggedInUserModel != null) {
      final result = await _userRepository.logLogoutTime(loggedInUserModel!.userId);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Logout time logged successfully!"),
      );
    }
  }

  @override
  void onClose() {
    userFormHandler.dispose();
    roleFormHandler.dispose();
    super.onClose();
  }
}
