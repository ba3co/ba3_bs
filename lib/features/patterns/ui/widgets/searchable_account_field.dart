import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_text_field_with_icon.dart';

class SearchableAccountField extends StatelessWidget {
  final String label;
  final TextEditingController textEditingController;
  final Function(String text)? onSubmitted;
  final bool isCustomerAccount; // Add this parameter to indicate customer account field

  const SearchableAccountField(
      {super.key,
      required this.label,
      required this.textEditingController,
      this.onSubmitted,
      this.isCustomerAccount = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width * 0.45,
      child: Row(
        children: [
          SizedBox(width: 100, child: Text(label)),
          Expanded(
            child: CustomTextFieldWithIcon(
              controller: textEditingController,
              onSubmitted: onSubmitted ??
                  (text) {
                    Get.find<AccountsController>().openAccountSelectionDialog(
                      query: text,
                      textEditingController: textEditingController,
                      isCustomerAccount: isCustomerAccount,
                    );
                  },
            ),
          ),
        ],
      ),
    );
  }
}
