import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_body.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_buttons.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_calculations.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_header.dart';
import 'package:ba3_bs/features/bill/ui/widgets/add_bill/add_bill_app_bar.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/add_bill_controller.dart';
import '../../data/datasources/bills_data_source.dart';
import '../../../../core/services/firebase/implementations/firebase_repo_with_result_impl.dart';
import '../../../../core/helper/enums/enums.dart';

class AddBillScreen extends StatelessWidget {
  const AddBillScreen({
    super.key,
    required this.billTypeModel,
    required this.fromBillDetails,
    required this.fromBillById,
    required this.firebaseApp,
  });

  final BillTypeModel billTypeModel;
  final bool fromBillDetails;
  final bool fromBillById;
  final FirebaseApp firebaseApp;

  @override
  Widget build(BuildContext context) {
    // Initialize Firestore with the provided FirebaseApp
    final firestore = FirebaseFirestore.instanceFor(app: firebaseApp);

    // Initialize the controller
    Get.put(
      AddBillController(FirebaseRepositoryWithResultImpl(BillsDataSource(firestore))),
    ).initCustomerAccount(billTypeModel.accounts?[BillAccounts.caches]);

    return MaterialApp(
      home: GetBuilder<AddBillController>(builder: (addBillController) {
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
              const VerticalSpace(20),
              AddBillBody(billTypeModel: billTypeModel),
              const VerticalSpace(10),
              const AddBillCalculations(),
              const Divider(),
              AddBillButtons(addBillController: addBillController, billTypeModel: billTypeModel),
            ],
          ),
        );
      }),
    );
  }
}
