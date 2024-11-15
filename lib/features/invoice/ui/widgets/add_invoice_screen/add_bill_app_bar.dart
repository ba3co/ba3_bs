import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/invoice/controllers/add_invoice_controller.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/helper/enums/enums.dart';

AppBar addBillAppBar(AddInvoiceController addInvoiceController, BillTypeModel billTypeModel) {
  return AppBar(
    leadingWidth: 100,
    centerTitle: true,
    leading: BackButton(
      onPressed: () {
        addInvoiceController.onBackPressed(billTypeModel.billTypeId!);
      },
    ),
    title: Text('${billTypeModel.fullName}'),
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
                          value: addInvoiceController.selectedPayType,
                          isExpanded: true,
                          onChanged: (payType) => addInvoiceController.onPayTypeChanged(payType),
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
          ],
        ),
      ),
      const HorizontalSpace(20),
    ],
  );
}
