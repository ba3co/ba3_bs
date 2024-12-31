import 'package:ba3_bs/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/widgets/searchable_account_field.dart';
import 'package:ba3_bs/core/widgets/store_dropdown.dart';
import 'package:ba3_bs/features/patterns/ui/widgets/add_pattern/text_field_with_label.dart';
import 'package:flutter/material.dart';

import '../../../controllers/pattern_controller.dart';
import 'pattern_type_dropdown.dart';

class AddPatternForm extends StatelessWidget {
  const AddPatternForm({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: patternController.patternFormHandler.formKey,
      child: Wrap(
        spacing: 20,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 10,
        children: [
          TextFieldWithLabel(
            label: 'الاختصار',
            textEditingController: patternController.patternFormHandler.shortNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاختصار'),
          ),
          TextFieldWithLabel(
            label: 'الاسم',
            textEditingController: patternController.patternFormHandler.fullNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم'),
          ),
          TextFieldWithLabel(
            label: 'اختصار لاتيني',
            textEditingController: patternController.patternFormHandler.latinShortNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'اختصار لاتيني'),
          ),
          TextFieldWithLabel(
            label: 'الاسم لاتيني',
            textEditingController: patternController.patternFormHandler.latinFullNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم لاتيني'),
          ),
          PatternTypeDropdown(patternController: patternController),
          if (patternController.selectedBillPatternType?.hasMaterialAccount ?? false)
            SearchableAccountField(
              label: 'المواد',
              textEditingController: patternController.patternFormHandler.materialsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'المواد'),
            ),
          if (patternController.selectedBillPatternType?.hasDiscountsAccount ?? false)
            SearchableAccountField(
              label: 'الحسميات',
              textEditingController: patternController.patternFormHandler.discountsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الحسميات'),
            ),
          if (patternController.selectedBillPatternType?.hasAdditionsAccount ?? false)
            SearchableAccountField(
              label: 'الاضافات',
              textEditingController: patternController.patternFormHandler.additionsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الاضافات'),
            ),
          if (patternController.selectedBillPatternType?.hasCashesAccount ?? false)
            SearchableAccountField(
              label: 'النقديات',
              textEditingController: patternController.patternFormHandler.cachesController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'النقديات'),
            ),
          if (patternController.selectedBillPatternType?.hasGiftsAccount ?? false)
            SearchableAccountField(
              label: 'الهدايا',
              textEditingController: patternController.patternFormHandler.giftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الهدايا'),
            ),
          if (patternController.selectedBillPatternType?.hasGiftsAccount ?? false)
            SearchableAccountField(
              label: 'مقابل الهدايا',
              textEditingController: patternController.patternFormHandler.exchangeForGiftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'مقابل الهدايا'),
            ),
          StoreDropdown(storeSelectionHandler: patternController.patternFormHandler),
        ],
      ),
    );
  }
}
