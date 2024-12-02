import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../../bill/controllers/bill/all_bills_controller.dart';

class AccountDetailsScreen extends StatelessWidget {
   AccountDetailsScreen({super.key});

  final String arguments = Get.arguments as String;


  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBillsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: "جميع الفواتير",
        onLoaded: (e) {},
        onSelected: (event) {
          String billId = event.row?.cells['billId']?.value;
          controller.openBillDetailsById(billId);
        },
        isLoading: controller.isLoading,
        tableSourceModels: controller.bills,
        icon: Icons.outbox,
        onIconPressed: controller.exportBillsJsonFile,
      );
    });
  }
}
