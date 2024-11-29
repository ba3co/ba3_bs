import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: addBillController.formKey,
        child: Column(
          children: [
            BillHeaderRow(
              firstItem: BillHeaderField(
                label: 'تاريخ الفاتورة',
                child: DatePicker(
                  initDate: addBillController.billDate,
                  onDateSelected: addBillController.setBillDate,
                ),
              ),
              secondItem: StoreDropdown(
                storeSelectionHandler: addBillController,
              ),
            ),
            const VerticalSpace(),
            BillHeaderRow(
              firstItem: BillHeaderField(
                label: 'رقم الجوال',
                child: CustomTextFieldWithoutIcon(
                  textEditingController: addBillController.mobileNumberController,
                  height: .038.sh,
                ),
              ),
              secondItem: SearchableAccountField(
                label: 'حساب العميل',
                height: .038.sh,
                textEditingController: addBillController.customerAccountController,
                validator: (value) => addBillController.validator(value, 'حساب العميل'),
                isCustomerAccount: true,
                fromAddBill: true,
              ),
            ),
            const VerticalSpace(),
            BillHeaderRow(
              firstItem: SearchableAccountField(
                label: 'البائع',
                height: .038.sh,
                textEditingController: addBillController.sellerAccountController,
                validator: (value) => addBillController.validator(value, 'البائع'),
                onSubmitted: (text) {
                  Get.find<SellerController>().openSellerSelectionDialog(
                      query: text, textEditingController: addBillController.sellerAccountController);
                },
              ),
              secondItem: BillHeaderField(
                label: 'البيان',
                child: CustomTextFieldWithoutIcon(
                  textEditingController: addBillController.noteController,
                  height: .038.sh,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BillHeaderRow extends StatelessWidget {
  const BillHeaderRow({super.key, required this.firstItem, required this.secondItem});

  final Widget firstItem;
  final Widget secondItem;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: firstItem),
        const HorizontalSpace(20),
        Expanded(child: secondItem),
      ],
    );
  }
}
