import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_body.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/bill/add_bill_controller.dart';
import '../widgets/add_bill/add_bill_app_bar.dart';
import '../widgets/add_bill/add_bill_buttons.dart';
import '../widgets/add_bill/add_bill_calculations.dart';
import '../widgets/add_bill/add_bill_header.dart';

class AddBillScreen extends StatelessWidget {
  const AddBillScreen({super.key, required this.billTypeModel});

  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) => GetBuilder<AddBillController>(builder: (addBillController) {
        return Scaffold(
          appBar: AddBillAppBar(billTypeModel: billTypeModel, addBillController: addBillController),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AddBillHeader(addBillController: addBillController),
              const VerticalSpace(20),
              AddBillBody(billTypeModel: billTypeModel),
              const VerticalSpace(10),
              const AddBillCalculations(),
              const Divider(),
              AddBillButtons(addBillController: addBillController, billTypeModel: billTypeModel),
            ],
          ),
        );
      });
}
