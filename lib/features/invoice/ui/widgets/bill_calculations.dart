import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/invoice_pluto_controller.dart';

class BillCalculations extends StatelessWidget {
  const BillCalculations({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoicePlutoController>(builder: (controller) {
      debugPrint('BillCalculations build');
      return SizedBox(
        width: Get.width,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          alignment: WrapAlignment.end,
          children: [
            Container(
              color: Colors.blueGrey.shade400,
              width: 150,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    (controller.computeWithVatTotal() - controller.computeWithoutVatTotal()).toStringAsFixed(2),
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  const Text(
                    "القيمة المضافة",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.grey.shade600,
              width: 150,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Text(
                    controller.computeWithoutVatTotal().toStringAsFixed(2),
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                  const Text(
                    "المجموع",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.blue,
              width: 300,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: ValueListenableBuilder<double>(
                      valueListenable: controller.vatTotalNotifier,
                      builder: (context, value, child) {
                        log('vatTotalNotifier changed $value');
                        // Call onAdditionsDiscountsChanged only if VAT changes
                        controller.updateDiscountCell(value);
                        return Text(
                          value.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 30,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'النهائي قبل الخصم',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.green,
              width: 300,
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: Text(
                      controller.computeTotalAfterDiscount().toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      'النهائي بعد الخصم',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
