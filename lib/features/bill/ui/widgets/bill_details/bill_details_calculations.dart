import 'package:ba3_bs/features/bill/ui/widgets/bill_details/bill_details_vat_total_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../bill_shared/calculation_card.dart';

class BillDetailsCalculations extends StatelessWidget {
  const BillDetailsCalculations({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillDetailsPlutoController>(
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
            BillDetailsVatTotalCard(width: 300, controller: controller),
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
