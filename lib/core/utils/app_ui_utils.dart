import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';
import '../widgets/app_spacer.dart';

class AppUIUtils {
  static void showToast(String text, {bool isSuccess = false, bool isInfo = false, bool long = false}) {
    Color color = Colors.red;
    if (isInfo) {
      color = Colors.orangeAccent;
    } else if (isSuccess) {
      color = Colors.green;
    }
    Fluttertoast.showToast(msg: text, backgroundColor: color, fontSize: 16.sp, toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT);
  }

  static String getDateFromString(String input) {
    DateTime now = DateTime.now();
    List<String> parts = input.split('-');

    if (parts.length == 3) {
      // صيغة اليوم-الشهر-السنة: 15-5-2023
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);
      return DateTime(year, month, day).toString().split(" ")[0];
    } else if (parts.length == 2) {
      // صيغة اليوم-الشهر: 15-5
      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = now.year;
      return DateTime(year, month, day).toString().split(" ")[0];
    } else if (parts.length == 1) {
      // صيغة اليوم فقط: 15
      int day = int.parse(parts[0]);
      int month = now.month;
      int year = now.year;
      return DateTime(year, month, day).toString().split(" ")[0];
    } else {
      // throw const FormatException("صيغة غير صحيحة");
      return DateTime.now().toString().split(" ")[0];
    }
  }

  static void showExportSuccessDialog(String filePath, String successMessage, String title) {
    AppUIUtils.onSuccess('تم تصدير الفواتير بنجاح!');
    Get.defaultDialog(
      title: 'تم تصدير الملف إلى:',
      radius: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      content: Column(
        children: [
          Text(filePath),
          const VerticalSpace(16),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('نسخ المسار'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              AppUIUtils.onSuccess('تم نسخ المسار إلى الحافظة');
            },
          ),
        ],
      ),
    );
  }

  static String getPageNameFromEnum(String type) {
    switch (type) {
      case AppConstants.roleViewInvoice:
        return "الفواتير";
      case AppConstants.roleViewBond:
        return "السندات";
      case AppConstants.roleViewAccount:
        return "الحسابات";
      case AppConstants.roleViewMaterial:
        return "المواد";
      case AppConstants.roleViewStore:
        return "المستودعات";
      case AppConstants.roleViewPattern:
        return "انماط البيع";
      case AppConstants.roleViewCheques:
        return "الشيكات";
      case AppConstants.roleViewSeller:
        return "البائعون";
      case AppConstants.roleViewReport:
        return "تقارير المبيعات";
      case AppConstants.roleViewImport:
        return "استيراد المعلومات";
      case AppConstants.roleViewTarget:
        return "التارغت";
      case AppConstants.roleViewTask:
        return "التاسكات";
      case AppConstants.roleViewInventory:
        return "الجرد";
      case AppConstants.roleViewUserManagement:
        return "إدارة المستخدمين";
      case AppConstants.roleViewDue:
        return "الاستحقاق";
      case AppConstants.roleViewStatistics:
        return "التقارير";
      case AppConstants.roleViewTimer:
        return "المؤقت";
      case AppConstants.roleViewDataBase:
        return "ادارة قواعد البيانات";
      case AppConstants.roleViewCard:
        return "ادارة البطاقات";
      case AppConstants.roleViewHome:
        return "الصفحة الرئيسية";
    }
    return "error";
  }

  static String getRoleNameFromEnum(String type) {
    switch (type) {
      case AppConstants.roleUserRead:
        return "القراءة";
      case AppConstants.roleUserWrite:
        return "الكتابة";
      case AppConstants.roleUserUpdate:
        return "التعديل";
      case AppConstants.roleUserDelete:
        return "الحذف";
      case AppConstants.roleUserAdmin:
        return "الإدارة";
    }
    return "error";
  }

  static Widget showLoadingIndicator({
    double width = 20,
    double height = 20,
    Color? color = Colors.white,
  }) =>
      Center(
        child: SizedBox(
            width: width,
            height: height,
            child: CircularProgressIndicator(
              color: color,
            )),
      );

  static showErrorSnackBar({String? title, required String message, NotificationStatus status = NotificationStatus.error}) {
    // Close any existing SnackBar
    Get.closeCurrentSnackbar();
    // Show the new SnackBar
    Get.snackbar(
      title ?? _getTitle(status),
      message,
      backgroundColor: const Color.fromARGB(50, 255, 0, 0),
      icon: const Icon(
        Icons.error_outline_outlined,
        color: Colors.white,
      ),
      barBlur: 50,
      colorText: Colors.white,
      // overlayBlur: 2,
      // overlayColor: const Color.fromARGB(10, 255, 0, 0),
    );
  }

  static showSuccessSnackBar({String? title, required String message, NotificationStatus status = NotificationStatus.success}) {
    // Close any existing SnackBar
    Get.closeCurrentSnackbar();
    // Show the new SnackBar
    Get.snackbar(
      title ?? _getTitle(status),
      message,
      backgroundColor: const Color.fromARGB(50, 0, 255, 0),
      icon: const Icon(
        Icons.check,
        color: Colors.white,
      ),
      barBlur: 50,
      colorText: Colors.white,
    );
  }

  static String _getTitle(NotificationStatus status) {
    switch (status) {
      case NotificationStatus.success:
        return 'نجاح';
      case NotificationStatus.error:
        return 'خطأ';
      case NotificationStatus.info:
        return 'تنبية';
    }
  }

  static onFailure(String message) => showErrorSnackBar(
        message: message,
      );

  static onSuccess(String message) => showSuccessSnackBar(message: message);
}
