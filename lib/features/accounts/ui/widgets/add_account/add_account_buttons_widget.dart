import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/utils/app_ui_utils.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/accounts_controller.dart';

class AddAccountButtonsWidget extends StatelessWidget {
  final AccountsController controller;

  const AddAccountButtonsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() {
          return AppButton(
            isLoading: controller.saveAccountRequestState.value ==
                RequestState.loading,
            title: controller.isEditAccount
                ? AppStrings.edit.tr
                : AppStrings.add.tr,
            onPressed: () {
              controller.saveOrUpdateAccount(context);
            },
          );
        }),
        if (controller.isEditAccount)
          Obx(() {
            return AppButton(
              isLoading: controller.deleteAccountRequestState.value ==
                  RequestState.loading,
              color: Colors.red,
              title: AppStrings.delete.tr,
              onPressed: () async {
                if (await AppUIUtils.confirmOverlay(context, canPop: true)) {
                  if (!context.mounted) return;
                  controller.deleteAccount(context);
                }
              },
            );
          }),
      ],
    );
  }
}