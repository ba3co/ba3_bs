import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/invoice/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../accounts/data/models/account_model.dart';
import '../../controllers/invoice_controller.dart';
import '../widgets/invoice_details_screen/bill_details_buttons.dart';
import '../widgets/invoice_details_screen/bill_details_header.dart';
import '../widgets/invoice_screen/bill_app_bar.dart';
import '../widgets/invoice_screen/bill_body.dart';
import '../widgets/invoice_screen/bill_calculations.dart';

class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key, required this.billModel, required this.customerAcc, required this.sellerAccName});

  final BillModel billModel;
  final AccountModel customerAcc;
  final String sellerAccName;

  @override
  Widget build(BuildContext context) => GetBuilder<InvoiceController>(builder: (invoiceController) {
        return Scaffold(
          appBar: billAppBar(invoiceController, billModel.billTypeModel),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BillDetailsHeader(
                invoiceController: invoiceController,
                billModel: billModel,
                customerAcc: customerAcc,
                sellerAccName: sellerAccName,
              ),
              const VerticalSpace(20),
              BillBody(billTypeModel: billModel.billTypeModel),
              const VerticalSpace(10),
              const BillCalculations(),
              const Divider(),
              BillDetailsButtons(
                invoiceController: invoiceController,
                billTypeModel: billModel.billTypeModel,
                billId: billModel.billId!,
              ),
            ],
          ),
        );
      });
}
