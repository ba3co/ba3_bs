import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/customer/controllers/customers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

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
    final customersController = read<CustomersController>();
    return Form(
      key: controller.accountFromHandler.formKey,
      child: Column(
        children: [
          FormFieldRow(
            firstItem: TextAndExpandedChildField(
              label: "اسم الحساب",
              child: CustomTextFieldWithoutIcon(
                suffixIcon: const SizedBox(),
                validator: (value) => controller.accountFromHandler.defaultValidator(value, "اسم الحساب"),
                textEditingController: controller.accountFromHandler.nameController,
              ),
            ),
            secondItem: TextAndExpandedChildField(
              label: "اسم الحساب اللاتيني",
              child: CustomTextFieldWithoutIcon(
                suffixIcon: const SizedBox(),
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
                if (accountModel != null) {
                  controller.setAccountParent(accountModel);
                }
              },
            ),
            secondItem: TextAndExpandedChildField(
              label: "رمز الحساب",
              child: CustomTextFieldWithoutIcon(
                suffixIcon: const SizedBox(),
                validator: (value) => controller.accountFromHandler.defaultValidator(value, "رمز الحساب"),
                textEditingController: controller.accountFromHandler.codeController,
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Dropdown for single customer selection
          FormFieldRow(
            firstItem: TextAndExpandedChildField(
              label: "اختيار عميل",
              child: Obx(() {
                return DropdownButtonFormField<String>(
                  value: customersController.selectedCustomer.value?.id,
                  items: customersController.customers.map((customer) {
                    return DropdownMenuItem<String>(
                      value: customer.id,
                      child: Text(customer.name!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    customersController.setSelectCustomer(value);
                  },
                );
              }),
            ),
            secondItem: TextAndExpandedChildField(
              label: "اختيار عملاء متعددين",
              child: Obx(() {
                return MultiSelectDialogField(
                  items: customersController.customers
                      .map((customer) => MultiSelectItem(customer.id, customer.name!))
                      .toList(),
                  title: const Text("اختر العملاء"),
                  buttonText: const Text("اختيار العملاء"),
                  initialValue: customersController.selectedCustomers.map((c) => c.id).toList(),
                  onConfirm: (selectedIds) {
                    customersController.setSelectedCustomers(List<String>.from(selectedIds));
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
