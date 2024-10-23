import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../controllers/pattern_controller.dart';

class PatternType extends StatelessWidget {
  const PatternType({
    super.key,
    required this.patternController,
  });

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.45,
      child: Row(
        children: [
          const SizedBox(width: 100, child: Text('نوع الفاتورة')),
          Container(
            width: (Get.width * 0.45) - 100,
            height: AppConstants.constHeightTextField,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Colors.white,
            ),
            child: DropdownButton(
                dropdownColor: Colors.white,
                focusColor: Colors.white,
                alignment: Alignment.center,
                underline: const SizedBox(),
                isExpanded: true,
                value: patternController.typeController.text.isEmpty
                    ? AppConstants.invoiceTypeSales
                    : patternController.typeController.text,
                items: const [
                  DropdownMenuItem(
                    value: AppConstants.invoiceTypeSales,
                    child: Center(
                      child: Text(
                        "مبيع",
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.invoiceTypeBuy,
                    child: Center(child: Text("شراء", textDirection: TextDirection.rtl)),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.invoiceTypeAdd,
                    child: Center(child: Text("إدخال", textDirection: TextDirection.rtl)),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.invoiceTypeChange,
                    child: Center(child: Text("تبديل مستودعي", textDirection: TextDirection.rtl)),
                  ),
                  DropdownMenuItem(
                    value: AppConstants.invoiceTypeSalesWithPartner,
                    child: Center(child: Text("مبيعات مع شريك", textDirection: TextDirection.rtl)),
                  ),
                ],
                onChanged: (_) {
                  patternController.typeController.text = _!;
                  patternController.editPatternModel?.patType = _;
                  if (patternController.typeController.text == AppConstants.invoiceTypeAdd) {
                    patternController.editPatternModel?.patPrimary = null;
                    patternController.primaryController.clear();
                  }
                  patternController.update();
                }),
          ),
        ],
      ),
    );
  }
}
