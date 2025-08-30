import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_drop_down.dart';

class OptionDropdownWidget extends StatelessWidget {
  const OptionDropdownWidget({
    required this.title,
    super.key,
    required this.value,
    required this.listValue,
    required this.label,
    required this.onChange,
  });

  final String title;
  final String value;
  final List<String> listValue;
  final String label;
  final void Function(String?) onChange;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 100, child: Text(title)),
          SizedBox(
            width: Get.width / 3,
            child: CustomDropDown(
              value: value,
              listValue: listValue,
              label: label,
              onChange: onChange,
            ),
          ),
        ],
      ),
    );
  }
}
