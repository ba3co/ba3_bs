import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_text_field_without_icon.dart';


class TextForm extends StatelessWidget {
  const TextForm({
    super.key,
    required this.text,
    required this.controller,
    this.onFieldSubmitted,
    this.onChanged,
  });

  final String text;
  final TextEditingController controller;
  final Function(String value)? onFieldSubmitted;
  final Function(String value)? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * .45,
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(text)),
          Expanded(
            child: CustomTextFieldWithoutIcon(
              onChanged: onChanged,
              onSubmitted: onFieldSubmitted,
              textEditingController: controller,
              // decoration: InputDecoration.collapsed(hintText: text),
            ),
          ),
        ],
      ),
    );
  }
}
