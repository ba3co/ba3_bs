import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bill/bill_details_controller.dart';
import '../widgets/bill_details/bill_details_app_bar.dart';
import '../widgets/bill_details/bill_details_body.dart';
import '../widgets/bill_details/bill_details_buttons.dart';
import '../widgets/bill_details/bill_details_calculations.dart';
import '../widgets/bill_details/bill_details_header.dart';

class BillDetailsScreen extends StatelessWidget {
  const BillDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) => GetBuilder<BillSearchController>(
        builder: (billSearchController) {
          return GetBuilder<BillDetailsController>(
            builder: (billDetailsController) {
              return Scaffold(
                appBar: BillDetailsAppBar(
                  billTypeModel: billSearchController.currentBill.billTypeModel,
                  billDetailsController: billDetailsController,
                  billSearchController: billSearchController,
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BillDetailsHeader(
                        billDetailsController: billDetailsController, billModel: billSearchController.currentBill),
                    const VerticalSpace(20),
                    BillDetailsBody(billTypeModel: billSearchController.currentBill.billTypeModel),
                    const VerticalSpace(10),
                    const BillDetailsCalculations(),
                    const Divider(),
                    BillDetailsButtons(
                        billDetailsController: billDetailsController, billModel: billSearchController.currentBill),
                  ],
                ),
              );
            },
          );
        },
      );
}
