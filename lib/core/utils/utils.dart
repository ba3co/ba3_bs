import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';

class Utils {
  static void showToast(String text, {bool isSuccess = false, bool isInfo = false, bool long = false}) {
    Color color = Colors.red;
    if (isInfo) {
      color = Colors.orangeAccent;
    } else if (isSuccess) {
      color = Colors.green;
    }
    Fluttertoast.showToast(
        msg: text, backgroundColor: color, fontSize: 16.sp, toastLength: long ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT);
  }

  static String formatSecretEmail(String email) {
    final firstPart = email.split("@").first;
    final lastPart = email.split("@").last;
    var secretFormatted = "";
    for (int i = 0; i < firstPart.length; i++) {
      secretFormatted += (i == 0 || i == firstPart.length - 1) ? firstPart[i] : "*";
    }
    return "$secretFormatted@$lastPart";
  }

  static DateTime? convertStringToDateTime(String? dateString) {
    if (dateString == null) return null;
    final DateFormat dateFormat;
    if (RegExp(r"\d+m").hasMatch(dateString)) {
      final minutes = int.parse(dateString.replaceAll("m", ""));
      return DateTime.now().add(Duration(minutes: minutes));
    } else {
      dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
    }
    return dateFormat.parse(dateString);
  }

  static String? convertDateTimeToString(DateTime? date) {
    if (date == null) return null;
    DateFormat dateFormat = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSSSS");
    return dateFormat.format(date);
  }

  static String capitalizeString({required String text}) {
    String newText = "";
    for (int i = 0; i < text.length; i++) {
      if (i == 0 || (i - 1 >= 0 && (text[i - 1] == " "))) {
        newText += text[i].toUpperCase();
      } else {
        newText += text[i];
      }
    }
    return newText;
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String convertFeetToFeetInches(double feet) {
    int feetPart = feet.floor();
    double inchesPart = (feet - feetPart) * 12.0;
    int inches = inchesPart.round();
    return '$feetPart\'$inches';
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

  static String generateId(RecordType recordType) {
    var epoch = DateTime.now().microsecondsSinceEpoch.toString();
    switch (recordType) {
      case RecordType.bond:
        return "bon$epoch";
      case RecordType.invoice:
        return "inv$epoch";
      case RecordType.product:
        return "prod$epoch";
      case RecordType.account:
        return "acc$epoch";
      case RecordType.pattern:
        return "pat$epoch";
      case RecordType.store:
        return "store$epoch";
      case RecordType.cheque:
        return "cheq$epoch";
      case RecordType.costCenter:
        return "CoCe$epoch";
      case RecordType.sellers:
        return "seller$epoch";
      case RecordType.user:
        return "user$epoch";
      case RecordType.role:
        return "role$epoch";
      case RecordType.task:
        return "task$epoch";
      case RecordType.inventory:
        return "inventory$epoch";
      case RecordType.entryBond:
        return "entryBond$epoch";
      case RecordType.accCustomer:
        return "accCustomer$epoch";
      case RecordType.warrantyInv:
        return "warrantyInv$epoch";
      case RecordType.changes:
        return "changes$epoch";
      case RecordType.fProduct:
        return "fProduct$epoch";
      case RecordType.undefined:
        return epoch;
    }
  }

  static String getStoreNameFromId(id) {
    if (id != null && id != " " && id != "") {
      //  return Get.find<StoreController>().storeMap[id]!.stName!;
      return "";
    } else {
      return "";
    }
  }

  static String getAccountNameById(id) {
    if (id != null && id != " " && id != "") {
//      return Get.find<AccountController>().accountList[id]?.accName ?? "$id";
      return "";
    } else {
      return "";
    }
  }

  static String getInvTypeFromEnum(String type) {
    switch (type) {
      case AppConstants.invoiceTypeSales:
        return "بيع";
      case AppConstants.invoiceTypeBuy:
        return "شراء";
      case AppConstants.invoiceTypeAdd:
        return "إدخال";
      case AppConstants.invoiceTypeChange:
        return "مناقلة";
      case AppConstants.invoiceTypeSalesWithPartner:
        return "مبيعات مع نسبة شريك";
    }
    return type;
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

  static showSnackBar(String title, String message) {
    Get.snackbar(title, message);
  }

  static String replaceArabicNumbersWithEnglish(String input) {
    return input.replaceAllMapped(RegExp(r'[٠-٩]'), (Match match) {
      return String.fromCharCode(match.group(0)!.codeUnitAt(0) - 0x0660 + 0x0030);
    });
  }

  static String extractNumbersAndCalculate(String input) {
    // استبدال الفاصلة العربية بالنقطة

    input = replaceArabicNumbersWithEnglish(input);
    String cleanedInput = input.replaceAll('٫', '.');

    // تحقق مما إذا كانت السلسلة تحتوي على معاملات حسابية
    bool hasOperators = cleanedInput.contains(RegExp(r'[+\-*/]'));

    // معالجة الفواصل الزائدة بحيث تبقى فقط الفاصلة الأولى
    cleanedInput = cleanedInput.replaceAllMapped(RegExp(r'(\d+)\.(\d+)\.(\d+)'), (match) {
      return '${match.group(1)}.${match.group(2)}';
    });
    if (hasOperators) {
      // إذا كان هناك معاملات، قم باستخراج الأرقام والعمليات وإجراء الحسابات
      RegExp regex = RegExp(r'[0-9.]+|[+\-*/]');
      Iterable<Match> matches = regex.allMatches(cleanedInput);
      List<String> elements = matches.map((match) => match.group(0)!).toList();

      List<double> numbers = [];
      String? operation;

      for (var element in elements) {
        if (double.tryParse(element) != null) {
          double number = double.parse(element);
          if (operation == null) {
            numbers.add(number);
          } else {
            double lastNumber = numbers.removeLast();
            switch (operation) {
              case '+':
                numbers.add(lastNumber + number);
                break;
              case '-':
                numbers.add(lastNumber - number);
                break;
              case '*':
                numbers.add(lastNumber * number);
                break;
              case '/':
                numbers.add(lastNumber / number);
                break;
            }
            operation = null;
          }
        } else {
          operation = element;
        }
      }

      return numbers.isNotEmpty ? numbers.first.toString() : "0.0";
    } else {
      //! إذا لم يكن هناك معاملات، فقط استخرج الأرقام /
      RegExp regex = RegExp(r'[0-9.]+');
      Iterable<Match> matches = regex.allMatches(cleanedInput);
      List<double> numbers = matches.map((match) => double.parse(match.group(0)!)).toList();

      // إذا لم توجد أرقام، قم بإرجاع 0
      return numbers.isNotEmpty ? numbers.first.toString() : "0.0";
    }
  }

  static String getAccountType(int? type) {
    switch (type) {
      case 0:
        return 'حساب عادي';
      case 1:
        return 'حساب ختامي';
      case 2:
        return 'حساب تجميعي';
      default:
        return 'حساب عادي';
    }
  }

  static String getAccountAccDebitOrCredit(int? type) {
    switch (type) {
      case 0:
        return 'Debit';
      case 1:
        return 'Credit';
      default:
        return 'Debit';
    }
  }
}
