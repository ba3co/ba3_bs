import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../controllers/invoice_controller.dart';
import '../../../controllers/invoice_pluto_controller.dart';
import '../../screens/invoice_screen.dart';
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
                  invoiceController.sellerController.clear();
                  invoiceController.initCustomerAccount(bill.accounts?[BillAccounts.caches]);
                  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                  Get.to(
                    () => InvoiceScreen(billTypeModel: bill),
                    binding: BindingsBuilder(() {
                      Get.lazyPut(() => InvoicePlutoController());
                    }),
                  );
                },
              ))
          .toList(),
    );
  }
}
