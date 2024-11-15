import 'package:ba3_bs/features/invoice/controllers/add_invoice_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../patterns/ui/widgets/searchable_account_field.dart';
import '../bill_header_field.dart';

class AddBillHeader extends StatelessWidget {
  const AddBillHeader({super.key, required this.addInvoiceController});

  final AddInvoiceController addInvoiceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Get.width - 20,
          child: Form(
            key: addInvoiceController.formKey,
            child: Wrap(
              spacing: 20,
              alignment: WrapAlignment.spaceBetween,
              runSpacing: 10,
              children: [
                BillHeaderField(
                  label: 'تاريخ الفاتورة :',
                  child: DatePicker(
                    initDate: addInvoiceController.billDate,
                    onDateSelected: addInvoiceController.setBillDate,
                  ),
                ),
                BillHeaderField(
                  label: 'المستودع :',
                  child: CustomTextFieldWithIcon(
                    controller: addInvoiceController.storeController,
                    onSubmitted: (text) {},
                    onIconPressed: () {},
                  ),
                ),
                BillHeaderField(
                  label: 'رقم الجوال :',
                  child: CustomTextFieldWithoutIcon(
                    controller: addInvoiceController.mobileNumberController,
                  ),
                ),
                SearchableAccountField(
                  label: 'حساب العميل :',
                  textEditingController: addInvoiceController.customerAccountController,
                  validator: (value) => addInvoiceController.validator(value, 'حساب العميل'),
                  isCustomerAccount: true,
                  fromAddBill: true,
                ),
                SearchableAccountField(
                  label: 'البائع :',
                  textEditingController: addInvoiceController.sellerAccountController,
                  validator: (value) => addInvoiceController.validator(value, 'البائع'),
                  onSubmitted: (text) {
                    Get.find<SellerController>().openSellerSelectionDialog(
                        query: text, textEditingController: addInvoiceController.sellerAccountController);
                  },
                ),
                BillHeaderField(
                  label: 'البيان',
                  child: CustomTextFieldWithoutIcon(
                    controller: addInvoiceController.noteController,
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
