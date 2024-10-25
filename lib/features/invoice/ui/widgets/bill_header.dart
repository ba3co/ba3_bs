import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/custom_text_field_with_icon.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../core/widgets/date_picker.dart';
import '../../controllers/invoice_controller.dart';

class BillHeader extends StatelessWidget {
  const BillHeader({
    super.key,
    required this.invoiceController,
  });

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
              SizedBox(
                width: Get.width * 0.45,
                child: Row(
                  children: [
                    const SizedBox(width: 100, child: Text("تاريخ الفاتورة : ", style: TextStyle())),
                    Expanded(
                      child: DatePicker(
                        initDate: invoiceController.billDate,
                        onSubmit: (_) {},
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Get.width * 0.45,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 100, child: Text("المستودع : ")),
                    Expanded(
                      child: CustomTextFieldWithIcon(
                          controller: invoiceController.storeController, onSubmitted: (text) {}, onIconPressed: () {}),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Get.width * 0.45,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 100, child: Text("رقم الجوال : ")),
                    Expanded(
                      child: CustomTextFieldWithoutIcon(controller: invoiceController.mobileNumberController),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Get.width * 0.45,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(width: 100, child: Text("حساب العميل : ")),
                    Expanded(
                      child: CustomTextFieldWithIcon(
                          controller: invoiceController.invCustomerAccountController,
                          onSubmitted: (text) async {},
                          onIconPressed: () {}),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Get.width * 0.45,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 100,
                      child: Text(
                        "البائع : ",
                      ),
                    ),
                    Expanded(
                      child: CustomTextFieldWithIcon(
                          controller: invoiceController.sellerController, onSubmitted: (text) async {}),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: Get.width * 0.45,
                child: Row(
                  children: [
                    const SizedBox(width: 100, child: Text("البيان")),
                    Expanded(
                      child: CustomTextFieldWithoutIcon(controller: invoiceController.noteController),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
