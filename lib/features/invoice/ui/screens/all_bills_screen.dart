import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/new_pluto.dart';
import '../../controllers/invoice_controller.dart';

class AllBillsScreen extends StatelessWidget {
  const AllBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoiceController>(builder: (controller) {
      return CustomPlutoGridWithAppBar(
        title: "جميع الفواتير",
        onLoaded: (e) {},
        onSelected: (event) {
          String billId = event.row?.cells['billId']?.value;
          controller.navigateToBillDetailsScreen(billId);
        },
        isLoading: controller.isLoading,
        tableSourceModels: controller.bills,
      );
    });
  }
}
