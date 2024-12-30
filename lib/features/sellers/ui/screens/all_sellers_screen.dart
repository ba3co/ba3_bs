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
        appBar: AppBar(
          title: const Text('جميع البائعون'),
        ),
        body: GetBuilder<SellersController>(builder: (controller) {
          return controller.sellers.isEmpty
              ? const Center(
                  child: Text('لا يوجد بائعون بعد'),
                )
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      children: List.generate(
                          controller.sellers.length,
                          (index) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: InkWell(
                                  onTap: () {
                                    // Get.to(() => AllSellerInvoicePage(
                                    //     oldKey: controller.sellers.toList()[index].costGuid));
                                  },
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
                                          controller.sellers.toList()[index].costCode?.toString() ?? '',
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        Text(
                                          controller.sellers.toList()[index].costName ?? '',
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
        }),
      ),
    );
  }
}
