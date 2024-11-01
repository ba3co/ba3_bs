import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/widgets/custom_text_field_without_icon.dart';
import '../../controllers/invoice_controller.dart';

AppBar buildAppBar(InvoiceController invoiceController, BillTypeModel billModel) {
  return AppBar(
    leadingWidth: 100,
    title: Text('${billModel.fullName}'),
    actions: [
      SizedBox(
        height: AppConstants.constHeightTextField,
        child: Row(
          children: [
            SizedBox(
              width: 250,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 80,
                    child: Text(
                      "نوع الفاتورة" ": ",
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  Expanded(
                    child: Container(
                        height: AppConstants.constHeightTextField,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black38),
                            borderRadius: BorderRadius.circular(8)),
                        child: DropdownButton(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          underline: const SizedBox(),
                          value: invoiceController.selectedPayType,
                          isExpanded: true,
                          onChanged: (payType) => invoiceController.onPayTypeChanged(payType),
                          items: InvPayType.values
                              .map((InvPayType type) => DropdownMenuItem<InvPayType>(
                                    value: type,
                                    child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          type.label,
                                          textDirection: TextDirection.rtl,
                                        )),
                                  ))
                              .toList(),
                        )),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.keyboard_double_arrow_right)),
                SizedBox(
                    width: Get.width * 0.10,
                    child: CustomTextFieldWithoutIcon(
                      isNumeric: true,
                      controller: invoiceController.invCodeController,
                      onSubmitted: (text) {},
                    )),
                IconButton(onPressed: () {}, icon: const Icon(Icons.keyboard_double_arrow_left)),
              ],
            ),
          ],
        ),
      ),
      const HorizontalSpace(20),
    ],
  );
}
