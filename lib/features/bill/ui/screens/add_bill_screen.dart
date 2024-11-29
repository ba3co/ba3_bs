import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_body.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/firebase/implementations/firebase_repo_with_result_impl.dart';
import '../../controllers/bill/add_bill_controller.dart';
import '../../data/models/bill_model.dart';
import '../widgets/add_bill/add_bill_app_bar.dart';
import '../widgets/add_bill/add_bill_buttons.dart';
import '../widgets/add_bill/add_bill_calculations.dart';
import '../widgets/add_bill/add_bill_header.dart';

class AddBillScreen extends StatelessWidget {
  const AddBillScreen(
      {super.key, required this.billTypeModel, required this.fromBillDetails, required this.fromBillById});

  final BillTypeModel billTypeModel;
  final bool fromBillDetails;
  final bool fromBillById;

  @override
  Widget build(BuildContext context) {
    Get.create(() => AddBillController(Get.find<FirebaseRepositoryWithResultImpl<BillModel>>()), permanent: false);
    Get.find<AddBillController>().initCustomerAccount(billTypeModel.accounts?[BillAccounts.caches]);

    return GetBuilder<AddBillController>(builder: (addBillController) {
      return Scaffold(
        appBar: AddBillAppBar(
          billTypeModel: billTypeModel,
          fromBillDetails: fromBillDetails,
          fromBillById: fromBillById,
          addBillController: addBillController,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddBillHeader(addBillController: addBillController),
            const VerticalSpace(5),
            AddBillBody(billTypeModel: billTypeModel),
            const VerticalSpace(5),
            const AddBillCalculations(),
            const Divider(height: 10),
            AddBillButtons(addBillController: addBillController, billTypeModel: billTypeModel),
          ],
        ),
      );
    });
  }
}
