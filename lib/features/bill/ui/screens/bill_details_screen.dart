import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bill/bill_details_controller.dart';
import '../widgets/bill_details/bill_details_app_bar.dart';
import '../widgets/bill_details/bill_details_body.dart';
import '../widgets/bill_details/bill_details_buttons.dart';
import '../widgets/bill_details/bill_details_calculations.dart';
import '../widgets/bill_details/bill_details_header.dart';

class BillDetailsScreen extends StatelessWidget {
  final bool fromBillById;

  const BillDetailsScreen({super.key, required this.fromBillById});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BillSearchController>(builder: (billSearchController) {
      final BillModel currentBill = billSearchController.getCurrentBill;
      return GetBuilder<BillDetailsController>(builder: (billDetailsController) {
        return Scaffold(
          appBar: BillDetailsAppBar(
            billTypeModel: currentBill.billTypeModel,
            billDetailsController: billDetailsController,
            billSearchController: billSearchController,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    BillDetailsHeader(billDetailsController: billDetailsController, billModel: currentBill),
                    const VerticalSpace(5),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: BillDetailsBody(billTypeModel: currentBill.billTypeModel)),
                    const VerticalSpace(10),
                    const Align(alignment: Alignment.centerLeft, child: BillDetailsCalculations()),
                    const Divider(height: 10),
                    BillDetailsButtons(
                      billDetailsController: billDetailsController,
                      billModel: currentBill,
                      fromBillById: fromBillById,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    });
  }
}
