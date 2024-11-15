import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillHeaderField extends StatelessWidget {
  final String label;
  final Widget child;

  const BillHeaderField({required this.label, required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.45,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
