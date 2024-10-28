import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/invoice_controller.dart';
import '../widgets/bill_app_bar.dart';
import '../widgets/bill_body.dart';
import '../widgets/bill_buttons.dart';
import '../widgets/bill_calculations.dart';
import '../widgets/bill_header.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key, required this.billModel});

  final BillTypeModel billModel;

  @override
  Widget build(BuildContext context) => GetBuilder<InvoiceController>(builder: (invoiceController) {
        return Scaffold(
          appBar: buildAppBar(invoiceController, billModel),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BillHeader(invoiceController: invoiceController),
              const VerticalSpace(20),
              BillBody(billTypeModel: billModel),
              const VerticalSpace(10),
              const BillCalculations(),
              const Divider(),
              BillButtons(invoiceController: invoiceController, billTypeLabel: billModel.billTypeLabel!),
            ],
          ),
        );
      });
}
