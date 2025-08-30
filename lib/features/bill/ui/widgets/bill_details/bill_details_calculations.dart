import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../bill_shared/calculation_card.dart';

class BillDetailsCalculations extends StatelessWidget {
  const BillDetailsCalculations({
    super.key,
    required this.tag,
    required this.billDetailsPlutoController,
    required this.billTypeModel,
  });

  final String tag;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillDetailsPlutoController>(
      tag: tag,
      builder: (_) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          alignment: WrapAlignment.end,
          runSpacing: 5.0,
          spacing: 5,
          children: [
            CalculationCard(
              visible: billTypeModel.billPatternType!.hasVat,
              height: 40.h,
              width: 40.0.w,
              color: Colors.blueGrey.shade400,
              value:
                  billDetailsPlutoController.computeTotalVat.toStringAsFixed(2),
              label: AppStrings.addedValue.tr,
            ),
            CalculationCard(
              visible: billTypeModel.billPatternType!.hasVat,
              height: 40.h,
              width: 40.0.w,
              color: Colors.blueGrey.shade400,
              value: billDetailsPlutoController.computeBeforeVatTotal
                  .toStringAsFixed(2),
              label: AppStrings.totalBeforeTax.tr,
            ),
            CalculationCard(
              visible: billTypeModel.billPatternType!.hasVat,
              height: 40.h,
              width: 40.0.w,
              color: Colors.grey.shade600,
              value: billDetailsPlutoController.computeWithVatTotal
                  .toStringAsFixed(2),
              label: AppStrings.subtotal.tr,
            ),
            CalculationCard(
              width: 40.0.w,
              height: 40.h,
              color: Colors.blue,
              value: billDetailsPlutoController.calculateFinalTotal
                  .toStringAsFixed(2),
              label: AppStrings.total.tr,
            ),
          ],
        ),
      ),
    );
  }
}
