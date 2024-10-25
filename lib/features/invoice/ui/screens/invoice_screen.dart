import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/invoice_controller.dart';
import '../widgets/bill_app_bar.dart';
import '../widgets/bill_body.dart';
import '../widgets/bill_buttons.dart';
import '../widgets/bill_header.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen(
      {super.key,
      required this.billId,
      required this.patternId,
      this.recentScreen = false,
      required this.billTypeModel});

  final String billId;
  final String patternId;
  final bool recentScreen;
  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InvoiceController>(builder: (invoiceController) {
      return Scaffold(
        appBar: buildAppBar(invoiceController, billTypeModel),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BillHeader(invoiceController: invoiceController),
            const VerticalSpace(20),
            BillBody(billTypeModel: billTypeModel),
            const Divider(),
            BillButtons(invoiceController: invoiceController),
          ],
        ),
      );
    });
  }
}
