import 'dart:developer';

import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:flutter/cupertino.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../../../controllers/accounts_controller.dart';

class AddAccountFormWidget extends StatelessWidget {
  const AddAccountFormWidget({super.key, required this.controller});

  final AccountsController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.accountFromHandler.formKey,
      child: Column(
        spacing: 15,
        children: [
          FormFieldRow(
            firstItem: TextAndExpandedChildField(
              label: "اسم الحساب",
              child: CustomTextFieldWithoutIcon(
                suffixIcon: SizedBox(),
                validator: (value) => controller.accountFromHandler.defaultValidator(value, "اسم الحساب"),
                textEditingController: controller.accountFromHandler.nameController,
              ),
            ),
            secondItem: TextAndExpandedChildField(
              label: "سم الحساب اللاتيني",
              child: CustomTextFieldWithoutIcon(
                suffixIcon: SizedBox(),
                textEditingController: controller.accountFromHandler.latinNameController,
              ),
            ),
          ),
          FormFieldRow(
            firstItem: SearchableAccountField(
              textEditingController: controller.accountFromHandler.accParentName,
              label: 'الحساب الاب',
              onSubmitted: (text) async {
                AccountModel? accountModel = await controller.openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                print(accountModel?.accName.toString());
                if (accountModel != null) {
                  controller.setAccountParent(accountModel);
                }
              },
            ),
            secondItem: TextAndExpandedChildField(
              label: "رمز الحساب",
              child: CustomTextFieldWithoutIcon(
                suffixIcon: SizedBox(),
                validator: (value) => controller.accountFromHandler.defaultValidator(value, "رمز الحساب"),
                textEditingController: controller.accountFromHandler.codeController,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
