import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/add_invoice_controller.dart';
import '../widgets/add_invoice_screen/add_bill_app_bar.dart';
import '../widgets/add_invoice_screen/add_bill_body.dart';
import '../widgets/add_invoice_screen/add_bill_buttons.dart';
import '../widgets/add_invoice_screen/add_bill_calculations.dart';
import '../widgets/add_invoice_screen/add_bill_header.dart';

class AddInvoiceScreen extends StatelessWidget {
  const AddInvoiceScreen({super.key, required this.billTypeModel});

  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) => GetBuilder<AddInvoiceController>(builder: (addInvoiceController) {
        return Scaffold(
          appBar: addBillAppBar(addInvoiceController, billTypeModel),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddBillHeader(addInvoiceController: addInvoiceController),
              const VerticalSpace(20),
              AddBillBody(billTypeModel: billTypeModel),
              const VerticalSpace(10),
              const AddBillCalculations(),
              const Divider(),
              AddBillButtons(addInvoiceController: addInvoiceController, billTypeModel: billTypeModel),
            ],
          ),
        );
      });
}
