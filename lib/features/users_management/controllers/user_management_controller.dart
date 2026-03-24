import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs/core/helper/mixin/app_navigator.dart';
import 'package:ba3_bs/core/models/query_filter.dart';
import 'package:ba3_bs/core/services/export_excl/excel_export.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:ba3_bs/features/user_task/controller/all_task_controller.dart';
import 'package:ba3_bs/features/user_task/data/model/user_task_model.dart';
import 'package:ba3_bs/features/user_time/data/models/leave_requests_model.dart';
import 'package:ba3_bs/features/users_management/services/role_service.dart';
import 'package:ba3_bs/features/users_management/services/user_navigator.dart';
import 'package:ba3_bs/features/users_management/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_constants.dart';
import '../../../core/network/error/failure.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import '../../../core/services/firebase/implementations/services/firestore_guest_user.dart';
import '../../../core/services/get_x/shared_preferences_service.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../floating_window/services/overlay_service.dart';
import '../data/models/role_model.dart';
import '../data/models/user_model.dart';
import '../services/role_form_handler.dart';

class UserManagementController extends GetxController
    with AppNavigator, FirestoreGuestUser {
  final RemoteDataSourceRepository<RoleModel> _rolesFirebaseRepo;

  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  final SharedPreferencesService _sharedPreferencesService;

  UserManagementController(this._rolesFirebaseRepo, this._usersFirebaseRepo,
      this._sharedPreferencesService);

  // Services
  late final RoleService _roleService;
  late final UserService _userService;
  late final UserNavigator userNavigator;

  UserTaskModel? selectedTask;

  // Form Handlers
  late final RoleFormHandler roleFormHandler;

  // Data
  List<RoleModel> allRoles = [];
  List<UserModel> allUsers = [];

  RoleModel? roleModel;

  UserModel? loggedInUserModel;

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

    roleFormHandler = RoleFormHandler();

    userNavigator = UserNavigator(roleFormHandler, _sharedPreferencesService);
  }

  List<UserModel> get nonLoggedInUsers => allUsers
      .where((user) => allUserIdsForChanges.contains(user.userId))
      .where((user) => user.userId != loggedInUserModel?.userId)
      .toList();

  List<String> get allUserIdsForChanges => [
        '0b0f8c5f-0dd0-4d58-a82f-c441476ab053',
        '3436769b-9ad9-4936-b217-6e8b0a7f7145',
        '3436769b-9ad9-4936-b217-6e8b0a7f7145',
        'cd88433b-5485-4dee-9596-8bae3c40e167',
        'fsCwYRtgG1SiTSJDfXXy',
        'kTnpg7ePEAjERvWzt6VQ',
        'xti265VhXe2DLVdeTgOR',
      ];
  List<UserTaskModel> get allTaskList =>
      loggedInUserModel?.userTaskList
          ?.where((element) => !element.status.isFinished)
          .toList() ??
      [];

  List<UserTaskModel> get allTaskListDone =>
      loggedInUserModel?.userTaskList
          ?.where((element) => element.status.isFinished)
          .toList() ??
      [];

  List<UserTaskModel> get saleTask => allTaskList
      .where(
        (element) => element.taskType == TaskType.saleTask,
      )
      .toList();

  List<UserTaskModel> get normalTask => allTaskList
      .where(
        (element) => element.taskType == TaskType.generalTask,
      )
      .toList();

  List<UserTaskModel> get inventoryTask => allTaskList
      .where(
        (element) => element.taskType == TaskType.inventoryTask,
      )
      .toList();

  String get dateToDay => Timestamp.now().toDate().toString().split(' ')[0];

  RoleModel? getRoleById(String id) {
    try {
      return allRoles.firstWhere((role) => role.roleId == id);
    } catch (e) {
      return null;
    }
  }

  // Check if all roles are selected
  bool areAllRolesSelected() => RoleItemType.values.every((type) =>
      roleFormHandler.rolesMap[type]?.length == RoleItem.values.length);

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
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
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
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (fetchedUsers) => _onGetAllUsersSuccess(fetchedUsers),
    );
  }

  void _onGetAllUsersSuccess(List<UserModel> fetchedUsers) {
    allUsers.assignAll(fetchedUsers);

    if (fetchedUsers.isNotEmpty) {
      final guestUser = fetchedUsers
          .firstWhereOrNull((user) => user.userName == ApiConstants.guest);

      checkGuestLoginButtonVisibility(guestUser);
    }
  }

  // Fetch user by ID using the repository
  Future<void> fetchAndHandleUser(String userId) async {
    final result = await _usersFirebaseRepo.getById(userId);

    result.fold(
      (failure) => _handleUserFetchFailure(
        failure,
      ),
      (user) => _handleUserFetchSuccess(
        user,
      ),
    );
  }

// Handle failure when fetching the user
  void _handleUserFetchFailure(Failure failure) {
    offAll(AppRoutes.loginScreen);
    AppUIUtils.onFailure(
      failure.message,
    );
  }

  void updatePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
    update();
  }

// Handle success when fetching the user
  void _handleUserFetchSuccess(UserModel userModel) {
    _populateLoginFields(userModel);
    validateUserInputs();
  }

// Check if the user is active
  bool _isUserActive(UserModel userModel) {
    if (userModel.userActiveStatus == UserActiveStatus.inactive) {
      AppUIUtils.onFailure(
        'حسابك غير نشط الان من فضلك حاول حقا!',
      );
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
      AppUIUtils.onFailure(
        'من فضلك قم بادخال اسم الحساب و الرقم السري!',
      );
      return;
    }

    if (loginPassword.length < 6) {
      AppUIUtils.onFailure(
        'من فضلك أدخل كلمة مرور مكونة من 6 أرقام على الأقل!',
      );
      return;
    }

    await _checkUserByPin();
  }

  Future<void> _checkUserByPin() async {
    final result = await _usersFirebaseRepo.fetchWhere(
      queryFilters: [
        QueryFilter(
            field: ApiConstants.userPassword,
            value: loginPasswordController.text)
      ],
    );
    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (fetchedUsers) => _handleGetUserPinSuccess(
        fetchedUsers,
      ),
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
      AppUIUtils.onFailure(
        'أسم المستخدم غير صحيح!',
      );
      return;
    }

    if (!_isUserActive(firstFetchedUser)) {
      if (currentRoute != AppRoutes.loginScreen) {
        offAll(AppRoutes.loginScreen);
      }
      return;
    }

    loggedInUserModel = firstFetchedUser;

    _sharedPreferencesService.setString(
        AppConstants.userIdKey, loggedInUserModel?.userId ?? '');
    offAll(AppRoutes.mainLayout);
  }

  Future<void> checkGuestLoginButtonVisibility(UserModel? guestUser) async {
    if (guestUser != null && guestUser.userId != null) {
      isGuestLoginButtonVisible.value =
          await isGuestUserEnabled(guestUser.userId!);
    }
  }

  Future<void> toggleGuestButtonVisibility() async {
    final guestUser =
        allUsers.firstWhere((user) => user.userName == ApiConstants.guest);
    await updateGuestUser(guestUser.userId!,
        visible: !isGuestLoginButtonVisible.value);

    isGuestLoginButtonVisible.value = !isGuestLoginButtonVisible.value;
  }

  Future<void> loginAsGuest() async {
    loggedInUserModel =
        allUsers.firstWhere((user) => user.userName == ApiConstants.guest);

    offAll(AppRoutes.mainLayout);
  }

  Future<void> _handleNoMatch() async {
    if (!isCurrentRoute(AppRoutes.loginScreen)) {
      userNavigator.navigateToLogin();
    } else {
      AppUIUtils.onFailure(
        'لا يوجد تطابق!',
      );
    }

    loginNameController.clear();
    loginPasswordController.clear();
  }

  Future<void> saveOrUpdateRole(
      {RoleModel? existingRoleModel, required BuildContext context}) async {
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
      AppUIUtils.onFailure(
        'من فضلك قم بادخال الصلاحيات!',
      );
      return;
    }

    final result = await _rolesFirebaseRepo.save(updatedRoleModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (success) {
        AppUIUtils.onSuccess(
          'تم حفظ او تعديل الدور بنجاح',
        );
        getAllRoles();
      },
    );
    update();
  }

  void logOut() {
    _sharedPreferencesService.remove(AppConstants.userIdKey);
    userNavigator.navigateToLogin();
  }

  @override
  void onClose() {
    roleFormHandler.dispose();
    super.onClose();
  }

  refreshLoggedInUser() async {
    final result = await _usersFirebaseRepo.getById(loggedInUserModel!.userId!);
    result.fold(
      (failure) => AppUIUtils.onFailure(
        failure.message,
      ),
      (fetchedUser) => loggedInUserModel = fetchedUser,
    );
  }

  List<UserModel> get filteredUsersWithDetails => allUsers
      .map((user) {
        final loginDelay = _userService.calculateTotalDelay(
            workingHours: user.userWorkingHours!,
            timeModel: user.userTimeModel![dateToDay],
            isLogin: true);
        final logoutDelay = _userService.calculateTotalDelay(
            workingHours: user.userWorkingHours!,
            timeModel: user.userTimeModel![dateToDay],
            isLogin: false);
        final haveHoliday =
            _userService.getIfHaveHoliday(dateToDay, user.userHolidays!);

        return user.copyWith(
          loginDelay: loginDelay,
          logoutDelay: logoutDelay,
          haveHoliday: haveHoliday,
        );
      })
      .where((user) =>
          user.loginDelay != null &&
          user.logoutDelay != null &&
          !(user.haveHoliday ?? false) &&
          user.userWorkingHours!.isNotEmpty)
      .toList();

  List<UserModel> get filteredAllUsersWithNunTime =>
      allUsers.where((user) => user.userWorkingHours!.isNotEmpty).toList();

  String getUserNameById(String id) {
    return allUsers.firstWhereOrNull((user) => user.userId == id)?.userName ??
        'invalid id $id';
  }

  addTaskToUser(UserTaskModel userTask, List<String> userToEdit) {
    List<UserModel> userToAddList = userToEdit
        .map((userId) => allUsers.firstWhere((user) => user.userId == userId))
        .toList();
    for (var user in userToAddList) {
      final List<UserTaskModel> updatedTaskList =
          List.from(user.userTaskList ?? []);

      int index = updatedTaskList
          .indexWhere((taskId) => taskId.docId == userTask.docId);

      if (index != -1) {
        updatedTaskList.removeAt(index);
        log("🗑️ تم حذف المهمة ذات ID: $userTask للمستخدم ${user.userName}");
      } else {
        updatedTaskList.add(userTask);
        log("✅ تم إضافة مهمة جديدة ذات ID: $userTask للمستخدم ${user.userName}");
      }

      final editedUser = user.copyWith(userTaskList: updatedTaskList);
      int allUsersIndex =
          allUsers.indexWhere((element) => element.userId == user.userId);

      if (allUsersIndex != -1) {
        allUsers[allUsersIndex] = editedUser; // Update the user in the list
      }
      _usersFirebaseRepo.save(editedUser);
    }
  }

  XFile? image;
  final ImagePicker _picker = ImagePicker();

  bool visiblePassword = false;

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = pickedFile;
      update();
    }
  }

  Future<int> getCurrentUserMaterialsSales(
      {required String materialId,
      required DateTime startDay,
      required DateTime endDay}) async {
    return await read<SellerSalesController>().getSellerMaterialsSales(
        sellerId: loggedInUserModel!.userSellerId!,
        dateTimeRange: DateTimeRange(start: startDay, end: endDay),
        materialId: materialId);
  }

/*'5eae14a3-aaa5-4309-bc44-f541def66fe1'*/
  void updateInventoryTask({required UserTaskModel task}) async {
    late UserTaskModel updatedTask;
    if (task.status.isInProgress) {
      OverlayService.back();
      updatedTask = task.copyWith(
        status: TaskStatus.done,
        endedAt: DateTime.now(),
      );
      // read<AllTaskController>().uploadDateTask(task: task, date: DateTime.now(), status: TaskStatus.done);
    } else {
      updatedTask = task.copyWith(
        status: TaskStatus.inProgress,
        updatedAt: DateTime.now(),
      );

      // read<AllTaskController>().uploadDateTask(task: task, date: DateTime.now(), status: TaskStatus.inProgress);
    }
    final updatedTaskList = [
      ...loggedInUserModel!.userTaskList!
          .where((element) => element.docId != updatedTask.docId),
      updatedTask
    ];

    _usersFirebaseRepo.save(
      loggedInUserModel!.copyWith(userTaskList: updatedTaskList),
    );
    // await fetchAllUserTask();
    update();
  }

  void updateGeneralTask({required UserTaskModel task}) async {
    if (image != null) {
      final imageUrl = await read<AllTaskController>().uploadImageTask(image!.path, "task/${task.docId}");


      final updatedTask = task.copyWith(
          status: TaskStatus.done,
          endedAt: DateTime.now(),
          taskImage: imageUrl);
      final updatedTaskList = [
        ...loggedInUserModel!.userTaskList!
            .where((element) => element.docId != updatedTask.docId),
        updatedTask
      ];

      _usersFirebaseRepo.save(
        loggedInUserModel!.copyWith(userTaskList: updatedTaskList),
      );
      image = null;
      OverlayService.back();
      update();
    }
  }

  UserModel? getUserBySellerId(String sellerId) {
    return allUsers.firstWhereOrNull((user) => user.userSellerId == sellerId);
  }

  List<Map<String, dynamic>> buildMonthlyRowsForUsers(
    List<UserModel> users, {
    required int month,
    required int year,
  }) {
    final List<Map<String, dynamic>> rows = [];

    final now = DateTime.now();

    final lastDay = (month == now.month && year == now.year)
        ? now.day
        : DateTime(year, month + 1, 0).day;

    for (final user in users) {
      /// 🔹 نحول العطل لكل مستخدم
      final holidaysSet = (user.userHolidays ?? []).map((e) {
        final date = DateTime.parse(e);
        return "${date.month}-${date.day}";
      }).toSet();

      for (int day = 1; day <= lastDay; day++) {
        final date = DateTime(year, month, day);
        final dateKey =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        final isHoliday = holidaysSet.contains("${date.month}-${date.day}");

        final model = user.userTimeModel?[dateKey];

        final shiftsText = user.userWorkingHours?.values
                .map((e) => "${e.enterTime ?? '-'}-${e.outTime ?? '-'}")
                .join(" / ") ??
            '';

        if (model == null || (model.logInDateList?.isEmpty ?? true)) {
          rows.add({
            "اسم الموظف": user.userName ?? '',
            "التاريخ": dateKey,
            "الشفتات الرسمية": shiftsText,
            "تسجيل الدخول": isHoliday ? "-" : "لا يوجد تسجيل",
            "تسجيل الخروج": isHoliday ? "-" : "لا يوجد تسجيل",
            "مدة الجلسة": "",
            "تأخير الدخول": "",
            "الخروج المبكر": "",
            "الوقت الإضافي": "",
            "حالة اليوم": isHoliday ? "عطلة" : "غياب",
          });

          continue;
        }

        final logInList = model.logInDateList ?? [];
        final logOutList = model.logOutDateList ?? [];

        final delayText = _formatMinutes(model.totalLogInDelay);
        final earlyText = _formatMinutes(model.totalOutEarlier);
        final extraText = _formatMinutes(model.totalExtraMinutes);

        for (int i = 0; i < logInList.length; i++) {
          final logIn = logInList[i];
          final logOut = i < logOutList.length ? logOutList[i] : null;

          rows.add({
            "اسم الموظف": i == 0 ? user.userName ?? '' : '',
            "التاريخ": i == 0 ? dateKey : '',
            "الشفتات الرسمية": i == 0 ? shiftsText : '',
            "تسجيل الدخول": _formatTime(logIn),
            "تسجيل الخروج":
                logOut != null ? _formatTime(logOut) : "لم يخرج بعد",
            "مدة الجلسة":
                logOut != null ? _calculateDuration(logIn, logOut) : "",
            "تأخير الدخول": i == 0 ? delayText : '',
            "الخروج المبكر": i == 0 ? earlyText : '',
            "الوقت الإضافي": i == 0 ? extraText : '',
            "حالة اليوم": i == 0 ? (isHoliday ? "عطلة" : "دوام") : '',
          });
        }
      }

      /// 🔥 سطر فارغ بين كل موظف وموظف
      rows.add(_emptyRow());
    }

    return rows;
  }

  List<Map<String, dynamic>> buildRowsFromToForUsers(
    List<UserModel> users, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final List<Map<String, dynamic>> rows = [];

    for (final user in users) {
      /// 🔹 نحول العطل لكل مستخدم (month-day فقط)
      final holidaysSet = (user.userHolidays ?? []).map((e) {
        final date = DateTime.parse(e);
        return "${date.month}-${date.day}";
      }).toSet();

      DateTime current = startDate;

      /// 🔹 تجهيز الإجازات المقبولة
      final leaveMap = <String, LeaveType>{};

      for (final UserLeaveRequestModel leave in user.userLeaveRequests ?? []) {
        if (leave.status != LeaveStatus.approved) continue;

        DateTime start = DateTime.parse(leave.startDate);
        DateTime end = DateTime.parse(leave.endDate);

        DateTime temp = start;

        while (!temp.isAfter(end)) {
          final key =
              "${temp.year}-${temp.month.toString().padLeft(2, '0')}-${temp.day.toString().padLeft(2, '0')}";

          leaveMap[key] = leave.leaveType;

          temp = temp.add(const Duration(days: 1));
        }
      }

      while (!current.isAfter(endDate)) {
        final dateKey =
            "${current.year}-${current.month.toString().padLeft(2, '0')}-${current.day.toString().padLeft(2, '0')}";

        final leaveType = leaveMap[dateKey];
        final isLeave = leaveType != null;
        final isHoliday =
            holidaysSet.contains("${current.month}-${current.day}") || isLeave;

        final model = user.userTimeModel?[dateKey];

        final shiftsText = user.userWorkingHours?.values
                .map((e) => "${e.enterTime ?? '-'}-${e.outTime ?? '-'}")
                .join(" / ") ??
            '';

        if (model == null || (model.logInDateList?.isEmpty ?? true)) {
          rows.add({
            "اسم الموظف": user.userName ?? '',
            "التاريخ": dateKey,
            "الشفتات الرسمية": shiftsText,
            "تسجيل الدخول": isHoliday ? "-" : "لا يوجد تسجيل",
            "تسجيل الخروج": isHoliday ? "-" : "لا يوجد تسجيل",
            "مدة الجلسة": "",
            "تأخير الدخول": "",
            "الخروج المبكر": "",
            "الوقت الإضافي": "",
            "حالة اليوم": isLeave
                ? "إجازة ${leaveType == LeaveType.sick ? "مرضية" : leaveType == LeaveType.paid ? "مدفوعة" : "غير مدفوعة"}"
                : (isHoliday ? "عطلة" : "غياب"),
          });

          current = current.add(const Duration(days: 1));
          continue;
        }

        final logInList = model.logInDateList ?? [];
        final logOutList = model.logOutDateList ?? [];

        final delayText = _formatMinutes(model.totalLogInDelay);
        final earlyText = _formatMinutes(model.totalOutEarlier);
        final extraText = _formatMinutes(model.totalExtraMinutes);

        for (int i = 0; i < logInList.length; i++) {
          final logIn = logInList[i];
          final logOut = i < logOutList.length ? logOutList[i] : null;

          rows.add({
            "اسم الموظف": i == 0 ? user.userName ?? '' : '',
            "التاريخ": i == 0 ? dateKey : '',
            "الشفتات الرسمية": i == 0 ? shiftsText : '',
            "تسجيل الدخول": _formatTime(logIn),
            "تسجيل الخروج":
                logOut != null ? _formatTime(logOut) : "لم يخرج بعد",
            "مدة الجلسة":
                logOut != null ? _calculateDuration(logIn, logOut) : "",
            "تأخير الدخول": i == 0 ? delayText : '',
            "الخروج المبكر": i == 0 ? earlyText : '',
            "الوقت الإضافي": i == 0 ? extraText : '',
            "حالة اليوم": i == 0
                ? (isLeave
                    ? "إجازة ${leaveType == LeaveType.sick ? "مرضية" : leaveType == LeaveType.paid ? "مدفوعة" : "غير مدفوعة"}"
                    : (isHoliday ? "عطلة" : "دوام"))
                : '',
          });
        }

        current = current.add(const Duration(days: 1));
      }

      /// 🔥 سطر فارغ بين كل موظف وموظف
      rows.add(_emptyRow());
    }

    return rows;
  }

  Map<String, dynamic> _emptyRow() {
    return {
      "اسم الموظف": "",
      "التاريخ": "",
      "الشفتات الرسمية": "",
      "تسجيل الدخول": "",
      "تسجيل الخروج": "",
      "مدة الجلسة": "",
      "تأخير الدخول": "",
      "الخروج المبكر": "",
      "الوقت الإضافي": "",
      "حالة اليوم": "",
    };
  }

  String _formatTime(DateTime time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _calculateDuration(DateTime start, DateTime end) {
    // إذا الخروج قبل الدخول → معناها قطع منتصف الليل
    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    final diff = end.difference(start);

    final h = diff.inHours;
    final m = diff.inMinutes.remainder(60);

    return "$h س $m د";
  }

  String _formatMinutes(int? minutes) {
    if (minutes == null || minutes == 0) return "0د";
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) {
      return "$h س $m د";
    }
    return "$m د";
  }

  Future<void> exportUsersMonthToExcel(
    List<UserModel> users, {
    required int month,
    required int year,
  }) async {
    final rows = buildMonthlyRowsForUsers(
      users,
      month: month,
      year: year,
    );

    if (rows.isEmpty) {
      AppUIUtils.onFailure("لا يوجد دوام لهذا الشهر");
      return;
    }

    await exportJsonToExcel(rows);
  }

  Future<void> exportUsersRangeToExcel(
    List<UserModel> users, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = buildRowsFromToForUsers(
      users,
      startDate: startDate,
      endDate: endDate,
    );

    if (rows.isEmpty) {
      AppUIUtils.onFailure("لا يوجد دوام في هذه الفترة");
      return;
    }

    await exportJsonToExcel(rows);
  }
}
