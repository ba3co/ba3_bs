import 'package:ba3_bs/features/patterns/ui/widgets/searchable_account_field.dart';
import 'package:ba3_bs/features/patterns/ui/widgets/text_field_with_label.dart';
import 'package:flutter/material.dart';

import '../../controllers/pattern_controller.dart';
import 'add_pattern_type.dart';

class AddPatternForm extends StatelessWidget {
  const AddPatternForm({super.key, required this.patternController});

  final PatternController patternController;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: patternController.formKey,
      child: Wrap(
        spacing: 20,
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 10,
        children: [
          TextFieldWithLabel(
            label: 'الاختصار',
            controller: patternController.shortNameController,
            validator: (value) => patternController.validator(value, 'الاختصار'),
          ),
          TextFieldWithLabel(
            label: 'الاسم',
            controller: patternController.fullNameController,
            validator: (value) => patternController.validator(value, 'الاسم'),
          ),
          TextFieldWithLabel(
            label: 'اختصار لاتيني',
            controller: patternController.latinShortNameController,
            validator: (value) => patternController.validator(value, 'اختصار لاتيني'),
          ),
          TextFieldWithLabel(
            label: 'الاسم لاتيني',
            controller: patternController.latinFullNameController,
            validator: (value) => patternController.validator(value, 'الاسم لاتيني'),
          ),
          PatternType(patternController: patternController),
          SearchableAccountField(label: 'المواد', controller: patternController.materialsController),
          SearchableAccountField(label: 'الحسميات', controller: patternController.discountsController),
          SearchableAccountField(label: 'الاضافات', controller: patternController.additionsController),
          SearchableAccountField(label: 'النقديات', controller: patternController.cachesController),
          SearchableAccountField(label: 'الهدايا', controller: patternController.giftsController),
          SearchableAccountField(label: 'مقابل الهدايا', controller: patternController.exchangeForGiftsController),
          SearchableAccountField(label: 'المستودع', controller: patternController.storeController),
        ],
      ),
    );
  }
}
