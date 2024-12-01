import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../bill_shared/calculation_card.dart';

class BillDetailsCalculations extends StatelessWidget {
  const BillDetailsCalculations({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillDetailsPlutoController>(
      builder: (controller) => Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        alignment: WrapAlignment.end,
        runSpacing: 10.0,
        children: [
          CalculationCard(
            color: Colors.blueGrey.shade400,
            value: controller.computeTotalVat.toStringAsFixed(2),
            label: 'القيمة المضافة',
          ),
          CalculationCard(
            color: Colors.blueGrey.shade400,
            value: controller.computeBeforeVatTotal.toStringAsFixed(2),
            label: 'المجموع قبل الضريبة',
          ),
          CalculationCard(
            color: Colors.grey.shade600,
            value: controller.computeWithVatTotal.toStringAsFixed(2),
            label: 'النهائي الجزئي',
          ),
          CalculationCard(
            width: 80.0.w,
            color: Colors.blue,
            value: controller.calculateFinalTotal.toStringAsFixed(2),
            label: 'النهائي',
          ),
        ],
      ),
    );
  }
}
