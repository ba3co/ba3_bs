import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_search_controller.dart';
import 'package:ba3_bs/features/invoice/ui/widgets/invoice_details_screen/bill_details_body.dart';
import 'package:ba3_bs/features/invoice/ui/widgets/invoice_details_screen/bill_details_calculations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/invoice_controller.dart';
import '../widgets/invoice_details_screen/bill_details_app_bar.dart';
import '../widgets/invoice_details_screen/bill_details_buttons.dart';
import '../widgets/invoice_details_screen/bill_details_header.dart';

class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<InvoiceSearchController>(
        builder: (invoiceSearchController) {
          return GetBuilder<InvoiceController>(
            builder: (invoiceController) {
              return Scaffold(
                appBar: billDetailsAppBar(invoiceController, invoiceSearchController.currentBill.billTypeModel),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BillDetailsHeader(
                        invoiceController: invoiceController, billModel: invoiceSearchController.currentBill),
                    const VerticalSpace(20),
                    BillDetailsBody(billTypeModel: invoiceSearchController.currentBill.billTypeModel),
                    const VerticalSpace(10),
                    const BillDetailsCalculations(),
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
