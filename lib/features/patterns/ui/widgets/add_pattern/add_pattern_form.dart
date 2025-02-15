import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/widgets/searchable_account_field.dart';
import 'package:ba3_bs/core/widgets/store_dropdown.dart';
import 'package:ba3_bs/features/patterns/ui/widgets/add_pattern/text_field_with_label.dart';
import 'package:flutter/material.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../accounts/controllers/accounts_controller.dart';
import '../../../../accounts/data/models/account_model.dart';
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
            label: AppStrings.al + AppStrings.short,
            textEditingController: patternController.patternFormHandler.shortNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاختصار'),
          ),
          TextFieldWithLabel(
            label: AppStrings.name,
            textEditingController: patternController.patternFormHandler.fullNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم'),
          ),
          TextFieldWithLabel(
            label: '${AppStrings.short} ${AppStrings.latin}',
            textEditingController: patternController.patternFormHandler.latinShortNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'اختصار لاتيني'),
          ),
          TextFieldWithLabel(
            label: '${AppStrings.latin} ${AppStrings.name}',
            textEditingController: patternController.patternFormHandler.latinFullNameController,
            validator: (value) => patternController.patternFormHandler.validator(value, 'الاسم لاتيني'),
          ),
          PatternTypeDropdown(patternController: patternController),
          if (patternController.selectedBillPatternType?.hasMaterialAccount ?? false)
            SearchableAccountField(
              label: AppStrings.materials,
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.materialsController.text = (accountModel.accName!);
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.materials, value: accountModel);
                }
              },
              textEditingController: patternController.patternFormHandler.materialsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'المواد'),
            ),
          if (patternController.selectedBillPatternType?.hasDiscountsAccount ?? false)
            SearchableAccountField(
              label: AppStrings.discounts,
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.discounts, value: accountModel);

                  patternController.patternFormHandler.discountsController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.discountsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الحسميات'),
            ),
          if (patternController.selectedBillPatternType?.hasAdditionsAccount ?? false)
            SearchableAccountField(
              label: AppStrings.additions,
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.additions, value: accountModel);

                  patternController.patternFormHandler.additionsController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.additionsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الاضافات'),
            ),
          if (patternController.selectedBillPatternType?.hasCashesAccount ?? false)
            SearchableAccountField(
              label: AppStrings.cashes,
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.caches, value: accountModel);

                  patternController.patternFormHandler.cachesController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.cachesController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'النقديات'),
            ),
          if (patternController.selectedBillPatternType?.hasGiftsAccount ?? false)
            SearchableAccountField(
              label: AppStrings.gifts,
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.materials, value: accountModel);

                  patternController.patternFormHandler.giftsController.text = (accountModel.accName!);
                }
              },
              textEditingController: patternController.patternFormHandler.giftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'الهدايا'),
            ),
          if (patternController.selectedBillPatternType?.hasGiftsAccount ?? false)
            SearchableAccountField(
              onSubmitted: (text) async {
                AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                  query: text,
                  context: context,
                );
                if (accountModel != null) {
                  patternController.patternFormHandler.addToSelectedAccounts(key: BillAccounts.exchangeForGifts, value: accountModel);

                  patternController.patternFormHandler.exchangeForGiftsController.text = (accountModel.accName!);
                }
              },
              label: '${AppStrings.exchange} ${AppStrings.gifts}',
              textEditingController: patternController.patternFormHandler.exchangeForGiftsController,
              validator: (value) => patternController.patternFormHandler.validator(value, 'مقابل الهدايا'),
            ),
          StoreDropdown(storeSelectionHandler: patternController.patternFormHandler),
        ],
      ),
    );
  }
}
