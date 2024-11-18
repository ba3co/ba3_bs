import 'package:ba3_bs/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../../core/widgets/searchable_account_field.dart';
import '../../../../../core/widgets/store_dropdown.dart';
import '../bill_shared/bill_header_field.dart';

class AddBillHeader extends StatelessWidget {
  const AddBillHeader({super.key, required this.addBillController});

  final AddBillController addBillController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Get.width - 20,
          child: Form(
            key: addBillController.formKey,
            child: Wrap(
              spacing: 20,
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              children: [
                BillHeaderField(
                  label: 'تاريخ الفاتورة :',
                  child: DatePicker(
                    initDate: addBillController.billDate,
                    onDateSelected: addBillController.setBillDate,
                  ),
                ),
                StoreDropdown(storeSelectionHandler: addBillController),
                BillHeaderField(
                  label: 'رقم الجوال :',
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: addBillController.mobileNumberController,
                  ),
                ),
                SearchableAccountField(
                  label: 'حساب العميل :',
                  textEditingController: addBillController.customerAccountController,
                  validator: (value) => addBillController.validator(value, 'حساب العميل'),
                  isCustomerAccount: true,
                  fromAddBill: true,
                ),
                SearchableAccountField(
                  label: 'البائع :',
                  textEditingController: addBillController.sellerAccountController,
                  validator: (value) => addBillController.validator(value, 'البائع'),
                  onSubmitted: (text) {
                    Get.find<SellerController>().openSellerSelectionDialog(
                        query: text, textEditingController: addBillController.sellerAccountController);
                  },
                ),
                BillHeaderField(
                  label: 'البيان',
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: addBillController.noteController,
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
