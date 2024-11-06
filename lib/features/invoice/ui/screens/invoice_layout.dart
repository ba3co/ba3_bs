import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/invoice_layout/display_all_billIs_button.dart';
import '../widgets/invoice_layout/invoice_layout_app_bar.dart';
import '../widgets/invoice_layout/invoice_layout_billIs.dart';

class InvoiceLayout extends StatelessWidget {
  const InvoiceLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: invoiceLayoutAppBar(),
        body: GetBuilder<InvoiceController>(
            builder: (invoiceController) => ListView(
                  padding: const EdgeInsets.all(15.0),
                  children: [
                    InvoiceLayoutBills(invoiceController: invoiceController),
                    const VerticalSpace(30),
                    DisplayAllBillsButton(
                      onTap: () {
                        invoiceController
                          ..fetchBills()
                          ..navigateToAllBillsScreen();
                      },
                    ),
                  ],
                )),
      ),
    );
  }
}
