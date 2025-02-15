import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/cupertino.dart';

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
        AppButton(
            title: controller.isEditAccount ? AppStrings.edit : AppStrings.add,
            onPressed: () {
              controller.saveOrUpdateAccount();
            }),
        if (controller.isEditAccount)
          AppButton(
              title: AppStrings.delete,
              onPressed: () {
                controller.deleteAccount();
              }),
      ],
    );
  }
}
