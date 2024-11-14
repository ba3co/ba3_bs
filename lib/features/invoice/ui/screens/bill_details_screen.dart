import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/invoice_controller.dart';
import '../widgets/invoice_details_screen/bill_details_buttons.dart';
import '../widgets/invoice_details_screen/bill_details_header.dart';
import '../widgets/invoice_screen/bill_app_bar.dart';
import '../widgets/invoice_screen/bill_body.dart';
import '../widgets/invoice_screen/bill_calculations.dart';

class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<InvoiceSearchController>(
        builder: (invoiceSearchController) {
          return GetBuilder<InvoiceController>(
            builder: (invoiceController) {
              return Scaffold(
                appBar: billAppBar(invoiceController, invoiceSearchController.currentBill.billTypeModel),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BillDetailsHeader(
                        invoiceController: invoiceController, billModel: invoiceSearchController.currentBill),
                    const VerticalSpace(20),
                    BillBody(billTypeModel: invoiceSearchController.currentBill.billTypeModel),
                    const VerticalSpace(10),
                    const BillCalculations(),
                    const Divider(),
                    BillDetailsButtons(
                        invoiceController: invoiceController, billModel: invoiceSearchController.currentBill),
                  ],
                ),
              );
            },
          );
        },
      );
}
