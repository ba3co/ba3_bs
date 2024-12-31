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
          SearchableAccountField(
            label: 'المواد',
            visible: patternController.selectedBillPatternType?.hasMaterialAccount,
            textEditingController: patternController.patternFormHandler.materialsController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'المواد'),
          ),
          SearchableAccountField(
            label: 'الحسميات',
            textEditingController: patternController.patternFormHandler.discountsController,
            visible:  patternController.selectedBillPatternType?.hasDiscountsAccount,
            //  validator: (value) => patternController.patternFormHandler.validator(value, 'الحسميات'),
          ),
          SearchableAccountField(
            label: 'الاضافات',
            visible:  patternController.selectedBillPatternType?.hasAdditionsAccount,
            textEditingController: patternController.patternFormHandler.additionsController,
            //   validator: (value) => patternController.patternFormHandler.validator(value, 'الاضافات'),
          ),
          SearchableAccountField(
            label: 'النقديات',
            textEditingController: patternController.patternFormHandler.cachesController,
            visible:  patternController.selectedBillPatternType?.hasCashesAccount,
            validator: (value) => patternController.patternFormHandler.validator(value, 'النقديات'),
          ),
          SearchableAccountField(
            label: 'الهدايا',
            visible:  patternController.selectedBillPatternType?.hasGiftsAccount,
            textEditingController: patternController.patternFormHandler.giftsController,
            //  validator: (value) => patternController.patternFormHandler.validator(value, 'الهدايا'),
          ),
          SearchableAccountField(
            label: 'مقابل الهدايا',
            visible:  patternController.selectedBillPatternType?.hasGiftsAccount,
            textEditingController: patternController.patternFormHandler.exchangeForGiftsController,
            //    validator: (value) => patternController.patternFormHandler.validator(value, 'مقابل الهدايا'),
          ),
          StoreDropdown(storeSelectionHandler: patternController.patternFormHandler),
        ],
      ),
    );
  }
}
