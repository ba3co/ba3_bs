import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/target_pointer_widget.dart';

class SellerTargetScreen extends StatelessWidget {
  const SellerTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SellerSalesController salesController = Get.find<SellerSalesController>();
    return Column(
      children: [
        Expanded(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              appBar: AppBar(
                actions: const [],
                title: Text(
                  '${AppStrings.panel.tr} ${AppStrings.achievements.tr}',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ),
              body: ListView(
                children: [
                  Row(
                    children: [
                      Column(
                        children: [
                          Text(
                            '${AppStrings.target.tr} ${AppStrings.mobiles.tr}',
                            style: TextStyle(fontSize: 22),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width / 2,
                              height: 500,
                              child: TargetPointerWidget(
                                maxValue: 350000,
                                midValue: 250000,
                                minValue: 150000,
                                key: salesController.mobilesKey,
                                value: salesController.totalMobilesSales,
                              )),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${AppStrings.target.tr} ${AppStrings.accessories.tr}',
                            style: TextStyle(fontSize: 22),
                          ),
                          SizedBox(
                              width: MediaQuery.sizeOf(context).width / 2,
                              height: 500,
                              child: TargetPointerWidget(
                                maxValue: 200000,
                                midValue: 150000,
                                minValue: 75000,
                                key: salesController.accessoriesKey,
                                value: salesController.totalAccessoriesSales,
                              )),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
