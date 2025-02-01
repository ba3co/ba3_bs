import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';

class TextAndExpandedChildField extends StatelessWidget {
  final String label;
  final Widget child;
  final double? width;
  final double? height;

  const TextAndExpandedChildField({super.key, required this.label, required this.child, this.width,this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height:height??AppConstants.constHeightTextField,

      width: width ?? Get.width * 0.45,
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle()),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
