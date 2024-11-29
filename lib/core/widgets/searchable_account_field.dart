import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'custom_text_field_with_icon.dart';

class SearchableAccountField extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final bool isCustomerAccount; // Add this parameter to indicate customer account field
  final bool fromAddBill; // Add this parameter to indicate customer account field
  final Function(String text)? onSubmitted;
  final FormFieldValidator<String>? validator;
  final double? height;
  final double? width;

  const SearchableAccountField({
    super.key,
    required this.label,
    required this.textEditingController,
    this.onSubmitted,
    this.validator,
    this.isCustomerAccount = false,
    this.fromAddBill = false,
    this.height,
    this.width,
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
              textEditingController: textEditingController,
              validator: validator,
              onSubmitted: onSubmitted ??
                  (text) {
                    Get.find<AccountsController>().openAccountSelectionDialog(
                      query: text,
                      textEditingController: textEditingController,
                      isCustomerAccount: isCustomerAccount,
                      fromAddBill: fromAddBill,
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}
