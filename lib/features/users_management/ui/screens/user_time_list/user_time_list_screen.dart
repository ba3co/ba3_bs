import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/dialogs/custom_alert_dialog/models/custom_alert_type.dart';
import 'package:ba3_bs/core/dialogs/custom_alert_dialog/widgets/custom_alert_dialog.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/pluto/controllers/pluto_controller.dart';
import 'package:ba3_bs/features/users_management/controllers/user_details_controller.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class UserTimeListScreen extends StatelessWidget {
  const UserTimeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final plutoController = read<PlutoController>();

    return GetBuilder<UserManagementController>(
        builder: (userManagementController) {
      return PlutoGridWithAppBar(
        bottomChild: AppButton(
          title: 'تصدير ملف الحضور',
          iconData: FontAwesomeIcons.fileExcel,
          onPressed: () async {
            final exportType = await showDialog<String>(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text("اختر نوع التصدير"),
                  content: const Text(
                      "هل تريد تصدير جميع الموظفين أم المحددين فقط؟"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, "all"),
                      child: const Text("الجميع"),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, "selected"),
                      child: const Text("المحددين فقط"),
                    ),
                  ],
                );
              },
            );

            if (exportType == null) return;

            final range = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );

            if (range == null) return;

            List<UserModel> users = [];

            if (exportType == "all") {
              users = userManagementController.filteredAllUsersWithNunTime;
            } else {
              final checkedRows =
                  plutoController.stateManager.rows.where((row) {
                return row.cells['extra_notes']?.value == 'true';
              }).toList();

              if (checkedRows.isEmpty) {
                await CustomAlertDialog.show(
                  type: CustomAlertType.warning,
                  text: "لم يتم تحديد أي مستخدم",
                );
                return;
              }

              final usersIds = checkedRows
                  .map((row) =>
                      row.cells[AppConstants.userIdFiled]?.value as String)
                  .toList();

              users = userManagementController.filteredAllUsersWithNunTime
                  .where((user) => usersIds.contains(user.userId))
                  .toList();
            }

            userManagementController.exportUsersRangeToExcel(
              users,
              startDate: range.start,
              endDate: range.end,
            );
          },
        ),
        title: AppStrings.allUsers.tr,
        isLoading: userManagementController.isLoading,
        rowHeight: 60,
        tableSourceModels: userManagementController.filteredAllUsersWithNunTime,
        onLoaded: (event) {},
        onSelected: (selectedRow) {
          final userId =
              selectedRow.row?.cells[AppConstants.userIdFiled]?.value;
          userManagementController.userNavigator.navigateToUserDetails(userId);
        },
      );
    });
  }
}
