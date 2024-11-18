import 'package:ba3_bs/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_vat_total_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bill_shared/calculation_card.dart';

class AddBillCalculations extends StatelessWidget {
  const AddBillCalculations({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddBillPlutoController>(
      builder: (controller) => SizedBox(
        width: Get.width,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          alignment: WrapAlignment.end,
          runSpacing: 10.0,
          children: [
            CalculationCard(
              width: 150,
              color: Colors.blueGrey.shade400,
              value: controller.computeTotalVat.toStringAsFixed(2),
              label: 'القيمة المضافة',
            ),
            CalculationCard(
              width: 150,
              color: Colors.blueGrey.shade400,
              value: controller.computeWithoutVatTotal.toStringAsFixed(2),
              label: 'المجموع قبل الضريبة',
            ),
            AddBillVatTotalCard(width: 300, controller: controller),
            CalculationCard(
              width: 300,
              color: Colors.blue,
              value: controller.calculateFinalTotal.toStringAsFixed(2),
              label: 'النهائي',
            ),
          ],
        ),
      ),
    );
  }
}
