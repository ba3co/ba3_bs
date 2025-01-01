import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/sellers_controller.dart';

class AllSellersScreen extends StatelessWidget {
  const AllSellersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('جميع البائعون')),
        body: GetBuilder<SellersController>(builder: (controller) {
          if (controller.isLoading) {
            return AppUIUtils.showLoadingIndicator();
          } else {
            if (controller.sellers.isEmpty) {
              return const Center(child: Text('لا يوجد بائعون بعد'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: Wrap(
                    children: List.generate(
                        controller.sellers.length,
                        (index) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () => read<SellerSalesController>().onSelectSeller(controller.sellers[index]),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(10)),
                                  height: 140,
                                  width: 140,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(
                                        controller.sellers[index].costCode?.toString() ?? '',
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      Text(
                                        controller.sellers[index].costName ?? '',
                                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )),
                  ),
                ),
              );
            }
          }
        }),
      ),
    );
  }
}
