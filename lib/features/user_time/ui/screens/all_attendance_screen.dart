import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AllAttendanceScreen extends StatelessWidget {
  const AllAttendanceScreen({super.key, required this.users});

  final List<UserModel> users;

  String? calculateTotalLoginDelay(Map<String, UserWorkingHours> workingHours, UserTimeModel? timeModel) {
    if (timeModel?.logInDateList == null || timeModel?.logInDateList?.length != workingHours.entries.length) {
      return "لم يسجل بعد";
    }
    int totalMinutes = 0;
    for (int i = 0; i < timeModel!.logInDateList!.length; i++) {
      final enterTime = DateFormat("hh:mm a").parse(workingHours.values.elementAt(i).enterTime!);
      final loginTime = timeModel.logInDateList!.elementAt(i);
      final delay = loginTime.difference(DateTime(loginTime.year, loginTime.month, loginTime.day, enterTime.hour, enterTime.minute));
      if (!delay.isNegative) {
        totalMinutes += delay.inMinutes;
      }
    }
    return totalMinutes > 0 ? formatDelay(totalMinutes) : null;
  }

  String? calculateTotalLogoutDelay(Map<String, UserWorkingHours> workingHours, UserTimeModel? timeModel) {
    if (timeModel?.logOutDateList == null || timeModel?.logInDateList?.length != workingHours.entries.length) {
      return "لم يسجل بعد";
    }
    int totalMinutes = 0;
    for (int i = 0; i < timeModel!.logOutDateList!.length; i++) {
      final enterTime = DateFormat("hh:mm a").parse(workingHours.values.elementAt(i).outTime!);
      final logOut = timeModel.logOutDateList!.elementAt(i);
      final delay = (DateTime(logOut.year, logOut.month, logOut.day, enterTime.hour, enterTime.minute)).difference(logOut);
      if (!delay.isNegative) {
        totalMinutes += delay.inMinutes;
      }
    }
    return totalMinutes > 0 ? formatDelay(totalMinutes) : null;
  }

  String formatDelay(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours == 0) {
      return "$minutes دقائق";
    } else if (minutes == 0) {
      return "$hours ساعات";
    } else {
      return "$hours ساعات و $minutes دقائق";
    }
  }

  bool getIfHaveHoliday(String dayName, List<String> userHolidays) {
    return userHolidays.contains(dayName);
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((user) {
      final loginDelay = calculateTotalLoginDelay(user.userWorkingHours!, user.userTimeModel!["2025-02-04"]);
      final logoutDelay = calculateTotalLogoutDelay(user.userWorkingHours!, user.userTimeModel!["2025-02-04"]);
      final haveHoliday = getIfHaveHoliday("2025-02-04", user.userHolidays!);
      return !(loginDelay == null && logoutDelay == null) && !haveHoliday;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("لوحة تحكم المستخدمين"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: filteredUsers.map((user) {
              final loginDelay = calculateTotalLoginDelay(user.userWorkingHours!, user.userTimeModel!["2025-02-04"]);
              final logoutDelay = calculateTotalLogoutDelay(user.userWorkingHours!, user.userTimeModel!["2025-02-04"]);
              return Container(
                padding: const EdgeInsets.all(8),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(color: Colors.grey.withOpacity(0.3), spreadRadius: 2, blurRadius: 5),
                  ],
                ),
                height: 130,
                width: 225,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Text(user.userName!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (loginDelay == "لم يسجل بعد" && logoutDelay == "لم يسجل بعد")
                      Text("لم يسجل بعد", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                    else ...[
                      Text("تأخير الدخول: ${loginDelay ?? 'لا يوجد'}"),
                      Text("الخروج مبكرا: ${logoutDelay ?? 'لا يوجد'}"),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
