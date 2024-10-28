import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../core/widgets/date_picker.dart';
import '../../controllers/invoice_controller.dart';
import 'bill_header_field.dart';

class BillHeader extends StatelessWidget {
  const BillHeader({super.key, required this.invoiceController});

  final InvoiceController invoiceController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: Get.width - 20,
          child: Wrap(
            spacing: 20,
            alignment: WrapAlignment.spaceBetween,
            runSpacing: 10,
            children: [
              BillHeaderField(
                label: 'تاريخ الفاتورة :',
                child: DatePicker(
                  initDate: invoiceController.billDate,
                  onSubmit: (_) {},
                ),
              ),
              BillHeaderField(
                label: 'المستودع :',
                child: CustomTextFieldWithIcon(
                  controller: invoiceController.storeController,
                  onSubmitted: (text) {},
                  onIconPressed: () {},
                ),
              ),
              BillHeaderField(
                label: 'رقم الجوال :',
                child: CustomTextFieldWithoutIcon(
                  controller: invoiceController.mobileNumberController,
                ),
              ),
              BillHeaderField(
                label: 'حساب العميل :',
                child: CustomTextFieldWithIcon(
                  controller: invoiceController.invCustomerAccountController,
                  onSubmitted: (text) async {},
                  onIconPressed: () {},
                ),
              ),
              BillHeaderField(
                label: 'البائع :',
                child: CustomTextFieldWithIcon(
                  controller: invoiceController.sellerController,
                  onSubmitted: (text) async {},
                ),
              ),
              BillHeaderField(
                label: 'البيان',
                child: CustomTextFieldWithoutIcon(
                  controller: invoiceController.noteController,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
