import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/patterns/ui/widgets/add_pattern/text_field_with_label.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../../../controllers/bonds/bond_type_controller.dart';
import 'bond_type_drop_down.dart';

class AddBondTypeForm extends StatelessWidget {
  const AddBondTypeForm({super.key, required this.controller});

  final BondTypeController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.bondTypeFormHandler.formKey,
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.spaceBetween,
        children: [

          //1. Bond Type Enum Dropdown
          BondTypeDropdown(bondController: controller),

          //2. Label and Value
          FormFieldRow(
            firstItem: TextFieldWithLabel(
              label: AppStrings.name.tr,
              textEditingController: controller.bondTypeFormHandler.labelController,
              validator: (value) => controller.bondTypeFormHandler.validator(value, 'الاسم'),
            ),
            secondItem: TextFieldWithLabel(
              label: AppStrings.latinName.tr,
              textEditingController: controller.bondTypeFormHandler.valueController,
              validator: (value) => controller.bondTypeFormHandler.validator(value, 'القيمة'),
            ),
          ),

          //3. Type Guide and Tax Type
          FormFieldRow(
            firstItem: TextFieldWithLabel(
              label: AppStrings.typeGuide.tr,
              textEditingController: controller.bondTypeFormHandler.typeGuideController,
              validator: (value) => controller.bondTypeFormHandler.validator(value, 'المرشد'),
            ),
            secondItem: TextFieldWithLabel(
              label: AppStrings.taxType.tr,
              textEditingController: controller.bondTypeFormHandler.taxTypeController,
              validator: (value) => controller.bondTypeFormHandler.validator(value, 'نوع الضريبة'),
            ),
          ),

          //4. Range (From - To)
          FormFieldRow(
            firstItem: TextFieldWithLabel(
              label: AppStrings.from.tr,
              textEditingController: controller.bondTypeFormHandler.fromController,
              validator: (value) => controller.bondTypeFormHandler.validator(value, 'من'),
            ),
            secondItem: TextFieldWithLabel(
              label: AppStrings.to.tr,
              textEditingController: controller.bondTypeFormHandler.toController,
              validator: (value) => controller.bondTypeFormHandler.validator(value, 'إلى'),
            ),
          ),
        ],
      ),
    );
  }
}
