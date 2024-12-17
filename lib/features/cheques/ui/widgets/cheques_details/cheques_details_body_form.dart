import 'package:ba3_bs/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';

class AddChequeForm extends StatelessWidget {
  const AddChequeForm({super.key, required this.chequesDetailsController});

  final ChequesDetailsController chequesDetailsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: chequesDetailsController.formKey,
        child: Column(
          children: [
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: 'تاريخ التحرير',
                  child: Obx(() {
                    return DatePicker(
                      initDate: chequesDetailsController.chequesDate.value,
                      onDateSelected: chequesDetailsController.setChequesDate,
                    );
                  }),
                ),
                secondItem: TextAndExpandedChildField(
                  label: "تاريخ الاستحقاق",
                  child: Obx(() {
                    return DatePicker(
                      initDate: chequesDetailsController.chequesDate.value,
                      onDateSelected: chequesDetailsController.setChequesDate,
                    );
                  }),
                )),
            const VerticalSpace(),
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: 'رقم الشيك',
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: TextEditingController(),
                    suffixIcon: const SizedBox.shrink(),
                  ),
                ),
                secondItem: TextAndExpandedChildField(
                  label: "قيمة الشيك",
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: TextEditingController(),
                    suffixIcon: const SizedBox.shrink(),
                  ),
                )),
            const VerticalSpace(),
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: 'الحساب',
                  child:CustomTextFieldWithoutIcon(
                    textEditingController: TextEditingController(),
                    suffixIcon: const SizedBox.shrink(),
                  ),
                ),
                secondItem: TextAndExpandedChildField(
                  label: "دفع إلى",
                  child:CustomTextFieldWithoutIcon(
                    textEditingController: TextEditingController(),
                    suffixIcon: const SizedBox.shrink(),
                  ),
                )),
            const VerticalSpace(),
            FormFieldRow(
                firstItem:      TextAndExpandedChildField(
                  label: "البيان",
                  child:CustomTextFieldWithoutIcon(
                    keyboardType: TextInputType.multiline,
                    maxLine:4,
                    textEditingController: TextEditingController(),
                    suffixIcon: const SizedBox.shrink(),
                  ),
                ),
                secondItem:      TextAndExpandedChildField(
                  label: "بيان الطرف الآخر",
                  child:CustomTextFieldWithoutIcon(
                    keyboardType: TextInputType.multiline,
                    maxLine:4,
                    textEditingController: TextEditingController(),
                    suffixIcon: const SizedBox.shrink(),
                  ),
                )),
            const VerticalSpace(),



          ],
        ),
      ),
    );


  }
}
