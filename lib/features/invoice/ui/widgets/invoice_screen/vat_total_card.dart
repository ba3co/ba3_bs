import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../controllers/invoice_pluto_controller.dart';

class VatTotalCard extends StatelessWidget {
  final double width;
  final InvoicePlutoController controller;

  const VatTotalCard({super.key, required this.width, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade600,
      width: width,
      height: .08.sh,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: FittedBox(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: ValueListenableBuilder<double>(
                valueListenable: controller.vatTotalNotifier,
                builder: (context, value, child) {
                  controller.updateAdditionDiscountCell(value);
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
                'النهائي الجزئي',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
