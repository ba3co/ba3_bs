import 'dart:developer';

import 'package:ba3_bs/features/users_management/services/role_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/helper/validators/app_validator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../core/services/firebase/implementations/filterable_data_source_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../login/data/models/user_model.dart';
import '../../login/data/repositories/user_repo.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';

class UserManagementController extends GetxController with AppValidator {
  final UserManagementRepository _userRepository;

  final DataSourceRepository<RoleModel> _rolesFirebaseRepo;

  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  UserManagementController(this._userRepository, this._rolesFirebaseRepo, this._usersFirebaseRepo);

  // Services
  late final RoleService _roleService;

  final userFormKey = GlobalKey<FormState>();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  List<RoleModel> allRoles = [];
  List<UserModel> allUsers = [];

  RoleModel? roleModel;
  UserModel? userModel;

  UserManagementStatus? userStatus;

  TextEditingController loginPasswordController = TextEditingController();
  TextEditingController loginNameController = TextEditingController();

  OldUserModel? myUserModel;

  final bool isAdmin = true;

  Map<RoleItemType, List<RoleItem>> rolesMap = {};

  final roleFormKey = GlobalKey<FormState>();
  TextEditingController roleNameController = TextEditingController();

  RxnString selectedSellerId = RxnString();
  RxnString selectedRoleId = RxnString();

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
  }

  bool validateRoleForm() => roleFormKey.currentState?.validate() ?? false;

  bool validateUserForm() => userFormKey.currentState?.validate() ?? false;

  String? validator(String? value, String fieldName) => isPasswordValid(value, fieldName);

  initUser(UserModel? user) {
    if (user != null) {
      userModel = user;

      selectedSellerId.value = user.userSellerId!;
      selectedRoleId.value = user.userRoleId!;

      userNameController.text = user.userName ?? '';
      passController.text = user.userPassword ?? '';
    } else {
      userModel = null;

      selectedSellerId.value = null; // Now valid with RxnString
      selectedRoleId.value = null; // Now valid with RxnString

      userNameController.clear();
      passController.clear();
    }
  }

  initRole(RoleModel? role) {
    if (role != null) {
      roleModel = role;
      rolesMap = role.roles;

      roleNameController.text = role.roleName ?? '';
    } else {
      roleModel = null;
      rolesMap = {};

      roleNameController.clear();
    }
  }

  RoleModel getRoleById(String id) => allRoles.firstWhere((role) => role.roleId == id);

  bool hasPermission(RoleItemType roleItemType) => _roleService.hasPermission(roleItemType);

  // Check if all roles are selected
  bool areAllRolesSelected() => RoleItemType.values.every((type) => rolesMap[type]?.length == RoleItem.values.length);

  // Check if all roles are selected for a specific RoleItemType
  bool areAllRolesSelectedForType(RoleItemType type) => rolesMap[type]?.length == RoleItem.values.length;

  // Select all roles
  void selectAllRoles() {
    for (final type in RoleItemType.values) {
      rolesMap[type] = RoleItem.values.toList();
    }
    update();
  }

  // Deselect all roles
  void deselectAllRoles() {
    rolesMap.clear();
    update();
  }

  // Select all roles for a specific RoleItemType
  void selectAllRolesForType(RoleItemType type) {
    rolesMap[type] = RoleItem.values.toList();
    update();
  }

  // Deselect all roles for a specific RoleItemType
  void deselectAllRolesForType(RoleItemType type) {
    rolesMap[type] = [];
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

    userModel = fetchedUsers.first;

    final isLoginNameMatch = userModel?.userName?.trim() == loginNameController.text;
    if (isLoginNameMatch) {
      Get.offAllNamed(AppRoutes.mainLayout);
    }
  }

  Future<void> _checkUserByPin() async {
    final result = await _usersFirebaseRepo.fetchWhere(field: 'userPassword', value: loginPasswordController.text);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUsers) => _handleGetUserPinSuccess(fetchedUsers),
    );
  }

  void navigateToLogin([bool waitUntilFirstFrameRasterized = false]) {
    if (waitUntilFirstFrameRasterized) {
      WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((_) {
        userStatus = UserManagementStatus.first;
        Get.offAllNamed(AppRoutes.loginScreen);
      });
    } else {
      userStatus = UserManagementStatus.first;
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  void navigateToAddRoleScreen([RoleModel? roleModel]) {
    initRole(roleModel);
    Get.toNamed(AppRoutes.addRoleScreen);
  }

  void navigateToAddUserScreen([UserModel? userModel]) {
    initUser(userModel);
    Get.toNamed(AppRoutes.addUserScreen);
  }

  void navigateToLAllUsersScreen() => Get.toNamed(AppRoutes.showAllUsersScreen);

  void navigateToLAllPermissionsScreen() => Get.toNamed(AppRoutes.showAllPermissionsScreen);

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

  set setSellerId(String? sellerId) {
    selectedSellerId.value = sellerId;
  }

  set setRoleId(String? roleId) {
    selectedRoleId.value = roleId;
  }

  Future<void> saveOrUpdateRole({RoleModel? existingRoleModel}) async {
    // Validate the form first
    if (!validateRoleForm()) return;

    // Create the role model from the provided data
    final updatedRoleModel =
        _roleService.createRoleModel(roleModel: existingRoleModel, roles: rolesMap, roleName: roleNameController.text);

    // Handle null role model
    if (updatedRoleModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات!');
      return;
    }

    final result = await _rolesFirebaseRepo.save(updatedRoleModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => AppUIUtils.onSuccess('تم الحفظ بنجاح'),
    );
  }

  Future<void> saveOrUpdateUser({UserModel? existingUserModel}) async {
    // Validate the form first
    if (!validateUserForm()) return;

    // Create the user model from the provided data
    final updatedUserModel = _roleService.createUserModel(
      userModel: existingUserModel,
      userName: userNameController.text,
      userPassword: passController.text,
      userRoleId: selectedRoleId.value,
      userSellerId: selectedSellerId.value,
    );

    // Handle null user model
    if (updatedUserModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات و البائع!');
      return;
    }

    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (success) => AppUIUtils.onSuccess('تم الحفظ بنجاح'),
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
    if (myUserModel != null) {
      final result = await _userRepository.logLoginTime(myUserModel!.userId);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Login time logged successfully!"),
      );
    }
  }

  // Log logout time
  Future<void> logOutTime() async {
    if (myUserModel != null) {
      final result = await _userRepository.logLogoutTime(myUserModel!.userId);
      result.fold(
        (failure) => Get.snackbar("Error", "جرب طفي التطبيق ورجاع شغلو او تأكد من اتصال النت  ${failure.message} \n"),
        (success) => Get.snackbar("Success", "Logout time logged successfully!"),
      );
    }
  }
}
