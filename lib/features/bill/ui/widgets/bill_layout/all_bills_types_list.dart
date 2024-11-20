import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';

import 'bill_type_item_widget.dart';

class AllBillsTypesList extends StatelessWidget {
  const AllBillsTypesList({super.key, required this.allBillsController});

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10.0,
      runSpacing: 2.0,
      children: allBillsController.billsTypes
          .map((billTypeModel) => BillITypeItemWidget(
                bill: billTypeModel,
                onPressed: () {
                  allBillsController.openLastBillDetails(billTypeModel);
                },
              ))
          .toList(),
    );
  }
}
