import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helper/extensions/getx_controller_extensions.dart';
import 'custom_text_field_with_icon.dart';

class SearchableMaterialField extends StatelessWidget {
  final String label;
  final Function(String text)? onSubmitted;
  final FormFieldValidator<String>? validator;
  final double? height;
  final double? width;
  final bool readOnly;

  const SearchableMaterialField({
    super.key,
    required this.label,
    this.onSubmitted,
    this.validator,
    this.height,
    this.width,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? Get.width * 0.45,
      height: height,
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: CustomTextFieldWithIcon(
              readOnly: readOnly,

              textEditingController: TextEditingController(),
              validator: validator,
              onSubmitted: onSubmitted ??
                  (text) {
                    read<MaterialController>().openMaterialSelectionDialog(
                      query: text,
                      context: context,
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}
