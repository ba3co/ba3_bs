import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../../bill/controllers/bill/all_bills_controller.dart';

class SellerSalesScreen extends StatelessWidget {
  const SellerSalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SellerSalesController>(
      builder: (controller) {
        return PlutoGridWithAppBar(
          title: 'فواتير',
          onLoaded: (e) {},
          onSelected: (event) {
            String billId = event.row?.cells['billId']?.value;
            read<AllBillsController>().openFloatingBillDetailsById(billId, context);
          },
          isLoading: controller.isLoading,
          tableSourceModels: controller.sellerBills,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'المجموع :',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
                    ),
                    const HorizontalSpace(10),
                    Text(
                      AppUIUtils.formatDecimalNumberWithCommas(controller.totalSales.value),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
