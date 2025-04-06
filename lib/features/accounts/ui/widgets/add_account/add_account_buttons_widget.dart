import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/accounts_controller.dart';

class AddAccountButtonsWidget extends StatelessWidget {
  final AccountsController controller;

  const AddAccountButtonsWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 20,
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
              title: AppStrings.delete.tr,
              onPressed: () {
                controller.deleteAccount(context);
              },
            );
          }),
      ],
    );
  }
}