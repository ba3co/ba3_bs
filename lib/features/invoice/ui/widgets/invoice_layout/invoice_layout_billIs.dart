import 'package:flutter/material.dart';

import '../../../controllers/invoice_controller.dart';
import 'bill_item_widget.dart';

class InvoiceLayoutBills extends StatelessWidget {
  const InvoiceLayoutBills({
    super.key,
    required this.invoiceController,
  });

  final InvoiceController invoiceController;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10.0,
      runSpacing: 2.0,
      children: invoiceController.billsTypes
          .map((bill) => BillItemWidget(
                bill: bill,
                invoiceController: invoiceController,
                onPressed: () {
                  invoiceController.openLastBillDetails(bill.billTypeId!);
                },
              ))
          .toList(),
    );
  }
}
