import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/print_controller.dart';

class PrintingLoadingDialog extends StatelessWidget {
  const PrintingLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Obx(() {
          // Observe dots and update text dynamically
          final dots = Get.find<PrintingController>().dots.value;
          return Text(
            'جاري الطباعه$dots',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          );
        }),
      ],
    );
  }
}
