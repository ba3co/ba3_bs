import 'package:ba3_bs/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../bill_shared/calculation_card.dart';

class AddBillCalculations extends StatelessWidget {
  const AddBillCalculations({
    super.key,
    required this.addBillPlutoController,
    required this.tag,
  });

  final AddBillPlutoController addBillPlutoController;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AddBillPlutoController>(
        tag: tag,
        builder: (_) {
          return Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            alignment: WrapAlignment.end,
            runSpacing: 10.0,
            children: [
              CalculationCard(
                color: Colors.blueGrey.shade400,
                value: addBillPlutoController.computeTotalVat.toStringAsFixed(2),
                label: 'القيمة المضافة',
              ),
              CalculationCard(
                color: Colors.blueGrey.shade400,
                value: addBillPlutoController.computeBeforeVatTotal.toStringAsFixed(2),
                label: 'المجموع قبل الضريبة',
              ),
              CalculationCard(
                color: Colors.grey.shade600,
                value: addBillPlutoController.computeWithVatTotal.toStringAsFixed(2),
                label: 'النهائي الجزئي',
              ),
              CalculationCard(
                color: Colors.blue,
                value: addBillPlutoController.calculateFinalTotal.toStringAsFixed(2),
                label: 'النهائي',
              ),
            ],
          );
        });
  }
}
