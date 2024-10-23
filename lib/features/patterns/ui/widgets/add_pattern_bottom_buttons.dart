import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../login/controllers/user_management_controller.dart';
import '../../controllers/pattern_controller.dart';

class AddPatternBottomButtons extends StatelessWidget {
  const AddPatternBottomButtons({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        AppButton(
            title: "جديد",
            onPressed: () {
              patternController.clearController();
            },
            iconData: Icons.open_in_new_outlined),
        AppButton(
          title: patternController.editPatternModel?.patId != null ? "تعديل" : "اضافة",
          onPressed: () {
            if (patternController.editPatternModel?.patName?.isEmpty ?? true) {
              Get.snackbar("خطأ", "يرجى كتابة الاسم");
            } else if (patternController.editPatternModel?.patCode?.isEmpty ?? true) {
              Get.snackbar("خطأ", "يرجى كتابة الرمز");
            } else if ((patternController.editPatternModel?.patPrimary?.isEmpty ?? true) &&
                patternController.editPatternModel?.patType != AppConstants.invoiceTypeAdd &&
                patternController.editPatternModel?.patType != AppConstants.invoiceTypeChange) {
              Get.snackbar("خطأ", "يرجى كتابة الحساب الاساسي");
            } else if ((patternController.editPatternModel?.patSecondary?.isEmpty ?? true) &&
                patternController.editPatternModel?.patType != AppConstants.invoiceTypeChange) {
              Get.snackbar("خطأ", "يرجى كتابة الحساب الثانوي");
            } else if (patternController.editPatternModel?.patType?.isEmpty ?? true) {
              Get.snackbar("خطأ", "يرجى كتابة نوع النمط");
            } else if (patternController.editPatternModel?.patStore?.isEmpty ?? true) {
              Get.snackbar("خطأ", "يرجى كتابة المستودع");
            } else {
              if (patternController.editPatternModel?.patId != null) {
                hasPermissionForOperation(AppConstants.roleUserUpdate, AppConstants.roleViewPattern).then((value) {
                  if (value) {
                    //   patternController.editPattern();
                  }
                });
              } else {
                hasPermissionForOperation(AppConstants.roleUserWrite, AppConstants.roleViewPattern).then((value) {
                  // if (value) patternController.addPattern();
                });
              }
            }
          },
          iconData: patternController.editPatternModel?.patId != null ? Icons.edit : Icons.add,
          color: patternController.editPatternModel?.patId != null ? Colors.green : null,
        ),
        if (patternController.editPatternModel?.patId != null)
          AppButton(
            title: "حذف",
            onPressed: () {
              hasPermissionForOperation(AppConstants.roleUserDelete, AppConstants.roleViewPattern).then((value) {
                if (value) {
                  patternController.deletePattern();
                }
              });
            },
            iconData: Icons.delete,
            color: Colors.red,
          )
      ],
    );
  }
}
