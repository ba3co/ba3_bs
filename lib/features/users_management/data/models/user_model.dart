import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/pluto/data/models/pluto_adaptable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_spacer.dart';
import '../../../../core/widgets/pluto_auto_id_column.dart';

class UserModel implements PlutoAdaptable {
  final String? userId;
  final String? userName;
  final String? userPassword;
  final String? userRoleId;
  final String? userSellerId;

  final UserWorkStatus? userWorkStatus;
  final UserActiveStatus? userActiveStatus;

  final List<String>? userHolidays;
  final Map<String, UserWorkingHours>? userWorkingHours;

  final Map<String, UserTimeModel>? userTimeModel;

  UserModel({
    this.userId,
    this.userName,
    this.userPassword,
    this.userRoleId,
    this.userSellerId,
    this.userTimeModel,
    this.userWorkStatus,
    this.userActiveStatus,
    this.userHolidays,
    this.userWorkingHours,
  });

  Map<String, dynamic> toJson() {
    return {
      'docId': userId,
      'userSellerId': userSellerId,
      'userName': userName,
      'userPassword': userPassword,
      'userRoleId': userRoleId,
      if (userActiveStatus != null) 'userActiveStatus': userActiveStatus?.label,
      if (userWorkStatus != null) 'userWorkStatus': userWorkStatus?.label,
      if (userHolidays != null) 'userHolidays': userHolidays?.toList(),
      if (userWorkingHours != null)
        'userWorkingHours': Map.fromEntries(userWorkingHours!.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()),
      if (userTimeModel != null) "userTime": Map.fromEntries(userTimeModel!.entries.map((e) => MapEntry(e.key, e.value.toJson())).toList()),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    Map<String, UserTimeModel> userTimeModel = <String, UserTimeModel>{};
    (json['userTime'] ?? {}).forEach((k, v) {
      userTimeModel[k] = UserTimeModel.fromJson(v);
    });

    Map<String, UserWorkingHours> userDailyTime = <String, UserWorkingHours>{};

    (json['userWorkingHours'] ?? {}).forEach(
      (String workingHourId, dynamic userWorkingHourJson) {
        userDailyTime[workingHourId] = UserWorkingHours.fromJson(userWorkingHourJson);
      },
    );

    return UserModel(
      userId: json['docId'],
      userSellerId: json['userSellerId'],
      userName: json['userName'],
      userPassword: json['userPassword'],
      userRoleId: json['userRoleId'],
      userHolidays: List<String>.from(json['userHolidays'] ?? []),
      userWorkingHours: userDailyTime,
      userWorkStatus: UserWorkStatus.byLabel(json['userWorkStatus'] ?? UserWorkStatus.away.label),
      userActiveStatus: json['userActiveStatus'] != null ? UserActiveStatus.byLabel(json['userActiveStatus']) : UserActiveStatus.inactive,
      userTimeModel: userTimeModel,
    );
  }

  /// Creates a copy of this UserModel with updated fields.
  UserModel copyWith({
    final String? userId,
    final String? userName,
    final String? userPassword,
    final String? userRoleId,
    final String? userSellerId,
    final UserWorkStatus? userWorkStatus,
    final UserActiveStatus? userActiveStatus,
    final List<String>? userHolidays,
    final Map<String, UserTimeModel>? userTimeModel,
    final Map<String, UserWorkingHours>? userWorkingHours,
  }) =>
      UserModel(
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        userPassword: userPassword ?? this.userPassword,
        userRoleId: userRoleId ?? this.userRoleId,
        userSellerId: userSellerId ?? this.userSellerId,
        userTimeModel: userTimeModel ?? this.userTimeModel,
        userWorkStatus: userWorkStatus ?? this.userWorkStatus,
        userActiveStatus: userActiveStatus ?? this.userActiveStatus,
        userHolidays: userHolidays ?? this.userHolidays,
        userWorkingHours: userWorkingHours ?? this.userWorkingHours,
      );

  @override
  Map<PlutoColumn, dynamic> toPlutoGridFormat([type]) {
    return {
      PlutoColumn(title: 'الرقم التعريفي', field: AppStrings.userIdFiled, type: PlutoColumnType.text(), hide: true): userId,
      createAutoIdColumn(): '',
      PlutoColumn(
        title: 'اسم الموظف',
        field: 'اسم الموظف',
        type: PlutoColumnType.text(),
      ): userName,
      PlutoColumn(
        title: 'الحالة',
        field: 'الحالة',
        textAlign: PlutoColumnTextAlign.center,
        renderer: (PlutoColumnRendererContext context) {
          String status = context.cell.value.toString();

          Color textColor = Colors.black;
          if (status != UserWorkStatus.online.label) {
            textColor = Colors.red;
          }

          return Center(
            child: Text(
              status,
              style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
            ),
          );
        },
        type: PlutoColumnType.text(),
      ): userWorkStatus?.label,
      PlutoColumn(
        title: 'اخر دخول',
        field: 'اخر دخول',
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): AppServiceUtils.formatDateTimeFromString(userTimeModel?.values.lastOrNull?.logInDateList?.lastOrNull?.toIso8601String()),
      PlutoColumn(
        title: 'اخر خروج',
        field: 'اخر خروج',
        textAlign: PlutoColumnTextAlign.center,
        type: PlutoColumnType.text(),
      ): AppServiceUtils.formatDateTimeFromString(userTimeModel?.values.lastOrNull?.logOutDateList?.lastOrNull?.toIso8601String()),
    };
  }
}

class UserWorkingHours {
  String? id;
  String? enterTime;
  String? outTime;

  UserWorkingHours({
    this.id,
    this.enterTime,
    this.outTime,
  });

  // Convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'enterTime': enterTime,
      'outTime': outTime,
    };
  }

  // Create object from JSON
  factory UserWorkingHours.fromJson(Map<String, dynamic> json) {
    return UserWorkingHours(
      id: json['id'] as String?,
      enterTime: json['enterTime'] as String?,
      outTime: json['outTime'] as String?,
    );
  }

  // Create a copy of the object with modified fields
  UserWorkingHours copyWith({
    String? id,
    String? enterTime,
    String? outTime,
  }) {
    return UserWorkingHours(
      id: id ?? this.id,
      enterTime: enterTime ?? this.enterTime,
      outTime: outTime ?? this.outTime,
    );
  }
}

class UserTimeModel {
  final String? dayName;
  final List<DateTime>? logInDateList;
  final List<DateTime>? logOutDateList;

  UserTimeModel({
    this.dayName,
    this.logInDateList,
    this.logOutDateList,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayName': dayName,
      if (logInDateList != null) 'logInDateList': logInDateList!.map((e) => e.toIso8601String()).toList(),
      if (logOutDateList != null) 'logOutDateList': logOutDateList!.map((e) => e.toIso8601String()).toList(),
    };
  }

  factory UserTimeModel.fromJson(Map<String, dynamic> json) {
    return UserTimeModel(
      dayName: json['dayName'] as String?,
      logInDateList: (json['logInDateList'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList(),
      logOutDateList: (json['logOutDateList'] as List<dynamic>?)?.map((e) => DateTime.parse(e as String)).toList(),
    );
  }

  UserTimeModel copyWith({
    String? dayName,
    List<DateTime>? logInDateList,
    List<DateTime>? logOutDateList,
  }) {
    return UserTimeModel(
      dayName: dayName ?? this.dayName,
      logInDateList: logInDateList ?? this.logInDateList,
      logOutDateList: logOutDateList ?? this.logOutDateList,
    );
  }
}
