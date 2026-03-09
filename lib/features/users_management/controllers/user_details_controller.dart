import 'package:ba3_bs/core/helper/extensions/date_time/time_extensions.dart';
import 'package:ba3_bs/core/services/export_excl/excel_export.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/user_time/data/models/leave_requests_model.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/target_model.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/dialogs/custom_date_picker_dialog.dart';
import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/network/error/failure.dart';
import '../../../core/services/firebase/implementations/repos/filterable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../changes/controller/changes_controller.dart';
import '../data/models/user_model.dart';
import '../services/role_form_handler.dart';
import '../services/user_form_handler.dart';
import '../services/user_service.dart';

class UserDetailsController extends GetxController {
  final FilterableDataSourceRepository<UserModel> _usersFirebaseRepo;

  late final UserFormHandler userFormHandler;
  late final RoleFormHandler roleFormHandler;

  // Services
  late final UserService _userService;

  Map<String, UserWorkingHours> workingHours = {};

  int get workingHoursLength => workingHours.length;

  Set<String> holidays = {};

  UserDetailsController(this._usersFirebaseRepo);

  int get holidaysLength => holidays.length;

  UserManagementController get allUserController =>
      read<UserManagementController>();

  // UserModel? get selectedUserModel => allUserController.selectedUserModel;
  UserModel? selectedUserModel;

  UserModel getUserById(String userId) => selectedUserModel =
      allUserController.allUsers.firstWhere((user) => user.userId == userId);

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  void _initializeServices() {
    _userService = UserService();

    userFormHandler = UserFormHandler();
    roleFormHandler = RoleFormHandler();

    // userNavigator = UserNavigator(roleFormHandler, userFormHandler, _sharedPreferencesService);
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
    workingHours[workingHoursLength.toString()] = UserWorkingHours(
        id: workingHoursLength.toString(),
        enterTime: "AM 12:00",
        outTime: "AM 12:00");
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
          final selectedDateList =
              dateRangePickerSelectionChangedArgs.value as List<DateTime>;
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

  UserModel? _createUserModel() => _userService.createUserModel(
        userModel: selectedUserModel,
        userName: userFormHandler.userNameController.text,
        userPassword: userFormHandler.passController.text,
        userRoleId: userFormHandler.selectedRoleId.value,
        userSellerId: userFormHandler.selectedSellerId.value,
        workingHour: workingHours,
        userActiveState: userFormHandler.userActiveStatus.value,
        holidays: holidays.toList(),
        groupTarget: TargetModel(1500, 0, 1100),
        groupForTarget: userFormHandler.selectedMaterialGroup,
        userSalary: userFormHandler.userSalaryController.text,
      );

  Future<void> saveOrUpdateUser(BuildContext context) async {
    // Validate the form first
    if (!userFormHandler.validate()) return;

    final updatedUserModel = _createUserModel();

    // Handle null user model
    if (updatedUserModel == null) {
      AppUIUtils.onFailure(
        'من فضلك قم بادخال الصلاحيات و البائع!',
      );
      return;
    }

    final result = await _usersFirebaseRepo.save(updatedUserModel);

    result.fold(
      (failure) => _handleFailure(failure, context),
      (userModel) => _onUserSaved(userModel, context),
    );
  }

  void _handleFailure(Failure failure, BuildContext context) =>
      AppUIUtils.onFailure(
        failure.message,
      );

  void _onUserSaved(UserModel userModel, BuildContext context) {
    AppUIUtils.onSuccess(
      'تم حفظ المستخدم بنجاح',
    );
    allUserController.getAllUsers();

    // Check if the user was newly saved
    final isSaved = selectedUserModel == null;
    if (isSaved) {
      _createChangeDocument(userModel.userId!, context);
    }
    update();
  }

  // Call the ChangesController to create the document
  Future<void> _createChangeDocument(
          String userId, BuildContext context) async =>
      await read<ChangesController>().createChangeDocument(userId, context);

  void initUserFormHandler(UserModel? user) {
    userFormHandler.init(user);
  }

  String userDelay(String dayName) {
    UserTimeModel? userTimeModel = selectedUserModel?.userTimeModel?[dayName];
    if (userTimeModel == null) return "";
    return AppServiceUtils.convertMinutesAndFormat(
        userTimeModel.totalLogInDelay ?? 0);
  }

  LeaveType? getLeaveTypeForDate(
    String dayName,
  ) {
    List<UserLeaveRequestModel>? leaves = selectedUserModel?.userLeaveRequests;

    if (leaves == null || leaves.isEmpty) return null;

    final targetDate = DateTime.parse(dayName);

    for (final leave in leaves) {
      if (leave.status != LeaveStatus.approved) continue;

      final start = DateTime.parse(leave.startDate);
      final end = DateTime.parse(leave.endDate);

      if (!targetDate.isBefore(start) && !targetDate.isAfter(end)) {
        return leave.leaveType;
      }
    }

    return null;
  }

  bool isHoliday(String dateKey) {
    final holidays = selectedUserModel?.userHolidays ?? [];

    if (holidays.isEmpty) return false;

    final monthDay = dateKey.substring(5); // 2026-03-01 -> 03-01

    final holidaysSet = holidays.map((e) {
      final d = DateTime.parse(e);
      return "${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
    }).toSet();

    final result = holidaysSet.contains(monthDay);

    return result;
  }

  String userEarlier(String dayName) {
    UserTimeModel? userTimeModel = selectedUserModel?.userTimeModel?[dayName];
    if (userTimeModel == null) return "";
    return AppServiceUtils.convertMinutesAndFormat(
        userTimeModel.totalOutEarlier ?? 0);
  }

  String userOverTime(String dayName) {
    UserTimeModel? userTimeModel = selectedUserModel?.userTimeModel?[dayName];
    if (userTimeModel == null) return "";
    return AppServiceUtils.convertMinutesAndFormat(
        userTimeModel.totalExtraMinutes ?? 0);
  }

  void resetDelay(BuildContext context) async {
    if (selectedUserModel?.userTimeModel == null) return;
    selectedUserModel!.userTimeModel!.forEach((key, value) {
      value.totalLogInDelay = 0;
      value.totalOutEarlier = 0;
    });
    if (selectedUserModel != null) {
      final result = await _usersFirebaseRepo.save(selectedUserModel!);
      result.fold(
        (failure) => _handleFailure(failure, context),
        (userModel) => _onUserSaved(userModel, context),
      );
    }

    update();
  }

  List<Map<String, dynamic>> buildRowsFromTo(
    UserModel user, {
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final List<Map<String, dynamic>> rows = [];

    /// 🔹 نحول العطل إلى Set (month-day)
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
          "تسجيل الخروج": logOut != null ? _formatTime(logOut) : "لم يخرج بعد",
          "مدة الجلسة": logOut != null ? _calculateDuration(logIn, logOut) : "",
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

    return rows;
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

  Future<void> exportUserRangeToExcel(
    UserModel user, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = buildRowsFromTo(
      user,
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
