import 'package:ba3_bs/core/widgets/store_dropdown.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../data/models/bill_model.dart';
import '../bill_shared/bill_header_field.dart';

class BillDetailsHeader extends StatelessWidget {
  const BillDetailsHeader({super.key, required this.billDetailsController, required this.billModel});

  final BillDetailsController billDetailsController;
  final BillModel billModel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Get.width - 20,
          child: Form(
            key: billDetailsController.formKey,
            child: Wrap(
              spacing: 20,
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              children: [
                BillHeaderField(
                  label: 'تاريخ الفاتورة :',
                  child: DatePicker(
                    initDate: billDetailsController.billDate,
                    onDateSelected: billDetailsController.setBillDate,
                  ),
                ),
                StoreDropdown(storeSelectionHandler: billDetailsController),
                BillHeaderField(
                  label: 'رقم الجوال :',
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: billDetailsController.mobileNumberController,
                  ),
                ),
                SearchableAccountField(
                  label: 'حساب العميل :',
                  textEditingController: billDetailsController.customerAccountController,
                  validator: (value) => billDetailsController.validator(value, 'حساب العميل'),
                  isCustomerAccount: true,
                  billController: billDetailsController,
                ),
                SearchableAccountField(
                  label: 'البائع :',
                  textEditingController: billDetailsController.sellerAccountController,
                  validator: (value) => billDetailsController.validator(value, 'البائع'),
                  onSubmitted: (text) {
                    Get.find<SellerController>().openSellerSelectionDialog(
                      query: text,
                      textEditingController: billDetailsController.sellerAccountController,
                      context: context,
                    );
                  },
                ),
                BillHeaderField(
                  label: 'البيان',
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: billDetailsController.noteController,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
