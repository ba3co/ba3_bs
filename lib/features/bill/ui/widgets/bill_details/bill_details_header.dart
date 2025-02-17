import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/widgets/store_dropdown.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../accounts/data/models/account_model.dart';
import '../../../../users_management/data/models/role_model.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../data/models/bill_model.dart';
import '../bill_shared/bill_header_field.dart';
import '../bill_shared/form_field_row.dart';

class BillDetailsHeader extends StatelessWidget {
  const BillDetailsHeader({
    super.key,
    required this.billDetailsController,
    required this.billModel,
  });

  final BillDetailsController billDetailsController;
  final BillModel billModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Form(
        key: billDetailsController.formKey,
        child: Column(
          children: [
            FormFieldRow(
              firstItem: TextAndExpandedChildField(
                label: AppStrings.billDate.tr,
                child: Obx(() {
                  return DatePicker(
                    initDate: billDetailsController.billDate.value.dayMonthYear,
                    onDateSelected: (date) {
                      billDetailsController.setBillDate = date;
                    },
                  );
                }),
              ),
              secondItem: StoreDropdown(storeSelectionHandler: billDetailsController),
            ),
            const VerticalSpace(5),
            FormFieldRow(
              visible: billModel.billTypeModel.billPatternType?.hasCashesAccount,
              firstItem: TextAndExpandedChildField(
                label: AppStrings.mobileNumber.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.mobileNumberController,
                  // suffixIcon: const SizedBox.shrink(),
                ),
              ),
              secondItem: SearchableAccountField(
                label: AppStrings.customerAccount.tr,
                textEditingController: billDetailsController.customerAccountController,
                validator: (value) => billDetailsController.validator(value, AppStrings.customerAccount.tr),
                onSubmitted: (text) async {
                  AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
                    query: text,
                    context: context,
                  );
                  if (accountModel != null) {
                    billDetailsController.updateCustomerAccount(accountModel);
                  }
                },
              ),
            ),
            const VerticalSpace(5),
            FormFieldRow(
              firstItem: SearchableAccountField(
                label: AppStrings.seller.tr,
                readOnly: !RoleItemType.viewBill.hasReadPermission,
                textEditingController: billDetailsController.sellerAccountController,
                onSubmitted: (text) {
                  read<SellersController>().openSellerSelectionDialog(
                    query: text,
                    textEditingController: billDetailsController.sellerAccountController,
                    context: context,
                  );
                },
              ),
              secondItem: TextAndExpandedChildField(
                label: AppStrings.illustration.tr,
                child: CustomTextFieldWithoutIcon(
                  textEditingController: billDetailsController.noteController,
                  suffixIcon: const SizedBox.shrink(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}