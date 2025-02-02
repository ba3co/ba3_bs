import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/dialogs/custom_date_picker_dialog.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/core/models/query_filter.dart';
import 'package:ba3_bs/features/changes/controller/changes_controller.dart';
import 'package:ba3_bs/features/users_management/services/role_service.dart';
import 'package:ba3_bs/features/users_management/services/user_service.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/error/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../core/services/firebase/implementations/services/firestore_guest_user.dart';
import '../../../core/services/get_x/shared_preferences_service.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';
import '../services/role_form_handler.dart';
import '../services/user_form_handler.dart';

class UserManagementController extends GetxController with AppNavigator, FirestoreGuestUser {
  final RemoteDataSourceRepository<RoleModel> _rolesFirebaseRepo;

  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  final SharedPreferencesService _sharedPreferencesService;

  UserManagementController(this._rolesFirebaseRepo, this._usersFirebaseRepo, this._sharedPreferencesService);

  // Services
  late final RoleService _roleService;
  late final UserService _userService;

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
  RxBool isGuestLoginButtonVisible = false.obs;
  bool isLoading = false;

  @override
  void onInit() {
    super.onInit();
    getAllUsers();
    getAllRoles();

    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _roleService = RoleService();
    _userService = UserService();

    userFormHandler = UserFormHandler();
    roleFormHandler = RoleFormHandler();
  }

  Map<String, UserWorkingHours> workingHours = {};

  int get workingHoursLength => workingHours.length;

  Set<String> holidays = {};

  int get holidaysLength => holidays.length;

  List<UserModel> get nonLoggedInUsers => allUsers
      .where(
        (user) => user.userId != loggedInUserModel?.userId,
      )
      .toList();

  RoleModel? getRoleById(String id) {
    try {
      return allRoles.firstWhere((role) => role.roleId == id);
    } catch (e) {
      return null;
    }
  }

  // Check if all roles are selected
  bool areAllRolesSelected() => RoleItemType.values.every((type) => roleFormHandler.rolesMap[type]?.length == RoleItem.values.length);

  // Check if all roles are selected for a specific RoleItemType
  bool areAllRolesSelectedForType(RoleItemType type) => roleFormHandler.rolesMap[type]?.length == RoleItem.values.length;

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
  }

  // Fetch roles using the repository
  Future<void> getAllUsers() async {
    log('getAllUsers');
    final result = await _usersFirebaseRepo.getAll();
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUsers) async {
        allUsers.assignAll(fetchedUsers);

        checkGuestLoginButtonVisibility(
          fetchedUsers.firstWhere((user) => user.userName == ApiConstants.guest),
        );
      },
    );
  }

  // Fetch user by ID using the repository
  Future<void> fetchAndHandleUser(String userId) async {
    final result = await _usersFirebaseRepo.getById(userId);

    result.fold(
      (failure) => _handleUserFetchFailure(failure),
      (user) => _handleUserFetchSuccess(user),
    );
  }

// Handle failure when fetching the user
  void _handleUserFetchFailure(Failure failure) {
    offAll(AppRoutes.loginScreen);
    AppUIUtils.onFailure(failure.message);
  }

// Handle success when fetching the user
  void _handleUserFetchSuccess(UserModel userModel) {
    _populateLoginFields(userModel);
    validateUserInputs();
  }

// Check if the user is active
  bool _isUserActive(UserModel userModel) {
    if (userModel.userActiveStatus == UserActiveStatus.inactive) {
      AppUIUtils.onFailure('حسابك غير نشط الان من فضلك حاول حقا!');
      return false;
    }
    return true;
  }

// Populate login fields with user data
  void _populateLoginFields(UserModel userModel) {
    loginNameController.text = userModel.userName ?? '';
    loginPasswordController.text = userModel.userPassword ?? '';
  }

  void validateUserInputs() async {
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

  Future<void> _checkUserByPin() async {
    final result = await _usersFirebaseRepo.fetchWhere(
      queryFilters: [QueryFilter(field: ApiConstants.userPassword, value: loginPasswordController.text)],
    );
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUsers) => _handleGetUserPinSuccess(fetchedUsers),
    );
  }

  void _handleGetUserPinSuccess(List<UserModel> fetchedUsers) async {
    if (fetchedUsers.isEmpty) {
      await _handleNoMatch();
      return;
    }
    final firstFetchedUser = fetchedUsers.firstWhereOrNull(
      (user) => user.userName == loginNameController.text,
    );

    if (firstFetchedUser == null) {
      AppUIUtils.onFailure('أسم المستخدم غير صحيح!');
      return;
    }

    if (!_isUserActive(firstFetchedUser)) {
      if (currentRoute != AppRoutes.loginScreen) {
        offAll(AppRoutes.loginScreen);
      }
      return;
    }

    loggedInUserModel = firstFetchedUser;

    _sharedPreferencesService.setString(AppConstants.userIdKey, loggedInUserModel?.userId ?? '');
    offAll(AppRoutes.mainLayout);
  }

  void navigateToLogin() async {
    debugPrint("navigateToLogin");
    if (_sharedPreferencesService.getString(AppConstants.userIdKey) == null) {
      offAll(AppRoutes.loginScreen);
    } else {
      fetchAndHandleUser(_sharedPreferencesService.getString(AppConstants.userIdKey)!);
    }
  }

  Future<void> checkGuestLoginButtonVisibility(UserModel guestUser) async {
    if (guestUser.userId != null) {
      isGuestLoginButtonVisible.value = await isGuestUserEnabled(guestUser.userId!);
    }
  }

  Future<void> toggleGuestButtonVisibility() async {
    final guestUser = allUsers.firstWhere((user) => user.userName == ApiConstants.guest);
    await updateGuestUser(guestUser.userId!, visible: !isGuestLoginButtonVisible.value);

    isGuestLoginButtonVisible.value = !isGuestLoginButtonVisible.value;
  }

  Future<void> loginAsGuest() async {
    loggedInUserModel = allUsers.firstWhere((user) => user.userName == ApiConstants.guest);

    offAll(AppRoutes.mainLayout);
  }

  void navigateToAddRoleScreen([RoleModel? role]) {
    roleFormHandler.init(role);
    to(AppRoutes.addRoleScreen);
  }

  void navigateToAddUserScreen([UserModel? user]) {
    userFormHandler.init(user);
    to(AppRoutes.addUserScreen);
  }

  void navigateToAllUsersScreen() => to(AppRoutes.showAllUsersScreen);

  void navigateToUserTimeListScreen() => to(AppRoutes.showUserTimeListScreen);

  void navigateToLAllPermissionsScreen() {
    log(allUsers.length.toString());
    to(AppRoutes.showAllPermissionsScreen);
  }

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
    update();
  }

  Future<void> saveOrUpdateUser() async {
    // Validate the form first
    if (!userFormHandler.validate()) return;

    final updatedUserModel = _createUserModel();

    // Handle null user model
    if (updatedUserModel == null) {
      AppUIUtils.onFailure('من فضلك قم بادخال الصلاحيات و البائع!');
      return;
    }

    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) => _handleFailure(failure),
      (userModel) => _onUserSaved(userModel),
    );
  }

  UserModel? _createUserModel() => _userService.createUserModel(
        userModel: selectedUserModel,
        userName: userFormHandler.userNameController.text,
        userPassword: userFormHandler.passController.text,
        userRoleId: userFormHandler.selectedRoleId.value,
        userSellerId: userFormHandler.selectedSellerId.value,
        workingHour: workingHours,
        userActiveState: userFormHandler.userActiveStatus.value,
        holidays: holidays.toList(),
      );

  void _handleFailure(Failure failure) => AppUIUtils.onFailure(failure.message);

  void _onUserSaved(UserModel userModel) {
    AppUIUtils.onSuccess('تم الحفظ بنجاح');
    getAllUsers();

    // Check if the user was newly saved
    final isSaved = selectedUserModel == null;
    if (isSaved) {
      _createChangeDocument(userModel.userId!);
    }
    update();
  }

  // Call the ChangesController to create the document
  Future<void> _createChangeDocument(String userId) async => await read<ChangesController>().createChangeDocument(userId);

  void logOut() {
    _sharedPreferencesService.remove(AppConstants.userIdKey);
    navigateToLogin();
  }

  setEnterTime(int index, Time time) {
    workingHours.values.elementAt(index).enterTime = time.formatToAmPm();
    update();
  }

  setOutTime(int index, Time time) {
    workingHours.values.elementAt(index).outTime = time.formatToAmPm();
    update();
  }

  void addWorkingHour() {
    workingHours[workingHoursLength.toString()] =
        UserWorkingHours(id: workingHoursLength.toString(), enterTime: "AM 12:00", outTime: "AM 12:00");
    update();
  }

  void deleteWorkingHour({required int key}) {
    workingHours.remove(key.toString());
    update();
  }

  void addHoliday() {
    Get.defaultDialog(
      title: 'أختر يوم',
      content: CustomDatePickerDialog(
        onClose: () {
          update();
          Get.back();
        },
        onTimeSelect: (dateRangePickerSelectionChangedArgs) {
          final selectedDateList = dateRangePickerSelectionChangedArgs.value as List<DateTime>;
          holidays.addAll(
            selectedDateList.map((e) => e.toIso8601String().split("T")[0]),
          );
        },
      ),
    );
  }

  void deleteHoliday({required String element}) {
    holidays.remove(element);
    update();
  }

  @override
  void onClose() {
    userFormHandler.dispose();
    roleFormHandler.dispose();
    super.onClose();
  }

  refreshLoggedInUser() async {
    final result = await _usersFirebaseRepo.getById(loggedInUserModel!.userId!);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedUser) => loggedInUserModel = fetchedUser,
    );
  }

  void navigateToUserDetails(String? userId) {
    selectedUserModel = allUsers.firstWhereOrNull(
      (user) => user.userId == userId,
    );
    to(AppRoutes.showUserDetails);
  }
}
