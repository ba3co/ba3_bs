import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../controllers/accounts_controller.dart';

class AllAccountScreen extends StatelessWidget {
  const AllAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allAccounts,
        onLoaded: (e) {},
        onSelected: (p0) {
          final String accId = p0.row?.cells['الرقم التعريفي']?.value;

          controller.navigateToAddOrUpdateAccountScreen(accountId: accId);
        },
        isLoading: controller.isLoading,
        tableSourceModels: controller.accounts,
      );
    });
  }
}
