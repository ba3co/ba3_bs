import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class AllBillsScreen extends StatelessWidget {
  const AllBillsScreen({super.key, required this.bills});

  final List<BillModel> bills;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBillsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allBills.tr,
        onLoaded: (e) {},
        onSelected: (event) {
          String billId = event.row?.cells[AppConstants.billIdFiled]?.value;
          controller.openFloatingBillDetailsById(billId, context, BillType.sales.billTypeModel);
        },
        isLoading: false,
        tableSourceModels: bills,
        icon: Icons.outbox,
        onIconPressed: controller.exportBillsJsonFile,
      );
    });
  }
}
