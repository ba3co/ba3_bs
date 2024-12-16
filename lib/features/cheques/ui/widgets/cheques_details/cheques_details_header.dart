import 'package:ba3_bs/core/widgets/searchable_account_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';
import '../../../controllers/cheques/cheques_details_controller.dart';

class ChequesDetailsHeader extends StatelessWidget {
  const ChequesDetailsHeader({
    super.key,
    required this.chequesDetailsController,
  });

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
                  label: 'تاريخ السند',
                  child: Obx(() {
                    return DatePicker(
                      initDate: chequesDetailsController.chequesDate.value,
                      onDateSelected: chequesDetailsController.setChequesDate,
                    );
                  }),
                ),
                secondItem: TextAndExpandedChildField(
                  label: "البيان",
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: chequesDetailsController.noteController,
                    suffixIcon: const SizedBox.shrink(),
                  ),
                )),
            const VerticalSpace(8),
            if (chequesDetailsController.isDebitOrCredit == true) ...[
              FormFieldRow(
                  firstItem: SearchableAccountField(

                    validator: (value) {
                      if (chequesDetailsController.isDebitOrCredit) {
                        return chequesDetailsController.validator(value, 'الحساب');
                      }
                      return null;
                    },
                    label: "الحساب : ",
                    textEditingController: chequesDetailsController.accountController,
                  ),
                  secondItem: Container()),
              const VerticalSpace(8),
            ]
          ],
        ),
      ),
    );
  }
}
