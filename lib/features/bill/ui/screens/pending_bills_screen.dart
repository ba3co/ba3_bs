import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class PendingBillsScreen extends StatelessWidget {
  const PendingBillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AllBillsController>(builder: (controller) {
      return PlutoGridWithAppBar(
        title: AppStrings.allBills.tr,
        onLoaded: (e) {},
        onSelected: (event) {
          String billId = event.row?.cells[AppConstants.billIdFiled]?.value;
          log('billId : $billId');
          controller.openFloatingBillDetailsById(billId, context, BillType.sales.billTypeModel);
        },
        isLoading: controller.isBillsLoading,
        tableSourceModels: controller.pendingBills.isEmpty?controller.bills:controller.pendingBills,
        bottomChild: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.totalSales.tr,
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    AppUIUtils.formatDecimalNumberWithCommas(controller.totalBillsSum),
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
                  ),
                ],
              ),

            ],
          ),
        ),

      );
    });
  }
}