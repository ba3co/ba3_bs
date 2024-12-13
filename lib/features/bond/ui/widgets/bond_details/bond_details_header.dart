import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:flutter/material.dart';
import '../../../../../core/widgets/app_spacer.dart';
import '../../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../../../../core/widgets/date_picker.dart';
import '../../../../bill/ui/widgets/bill_shared/bill_header_field.dart';
import '../../../../bill/ui/widgets/bill_shared/form_field_row.dart';

class BondDetailsHeader extends StatelessWidget {
  const BondDetailsHeader({
    super.key,
    required this.bondDetailsController,
  });

  final BondDetailsController bondDetailsController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Form(
        key: bondDetailsController.formKey,
        child: Column(
          children: [
            FormFieldRow(
                firstItem: TextAndExpandedChildField(
                  label: 'تاريخ السند',
                  child: DatePicker(
                    initDate: bondDetailsController.bondDate,
                    onDateSelected: bondDetailsController.setBondDate,
                  ),
                ),
                secondItem: TextAndExpandedChildField(
                  label: "البيان",
                  child: CustomTextFieldWithoutIcon(
                    textEditingController: bondDetailsController.noteController,
                    suffixIcon: const SizedBox.shrink(),
                  ),
                )),
            const VerticalSpace(8),
            if (bondDetailsController.isDebitOrCredit == true) ...[
              FormFieldRow(
                  firstItem: TextAndExpandedChildField(
                    label: "الحساب : ",
                    child: CustomTextFieldWithoutIcon(
                      textEditingController: bondDetailsController.accountController,
                      suffixIcon: const SizedBox.shrink(),
                    ),
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
