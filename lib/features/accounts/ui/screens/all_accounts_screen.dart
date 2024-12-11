import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
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
        title: 'جميع الحسابات',
        onLoaded: (e) {},
        onSelected: (p0) {
          final String accId = p0.row?.cells['الرقم التعريفي']?.value;

          final billController = Get.find<AllBillsController>();
          for (var bill in controller.accounts
                  .where(
                    (element) => element.id == accId,
                  )
                  .first
                  .billsId ??
              []) {
            billController.fetchAccountBills(bill);
          }

          controller.navigateToAccountDetailsScreen(accId);
        },
        isLoading: controller.isLoading,
        tableSourceModels: controller.accounts,
      );
    });
  }
}
