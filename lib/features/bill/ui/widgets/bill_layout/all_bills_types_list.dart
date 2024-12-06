import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'bill_type_item_widget.dart';

class AllBillsTypesList extends StatelessWidget {
  const AllBillsTypesList({super.key, required this.allBillsController});

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      spacing: 10.w,
      runSpacing: 10.0.h,
      children: allBillsController.billsTypes
          .map((billTypeModel) => BillITypeItemWidget(
                bill: billTypeModel,
                onPressed: () {
                  allBillsController.openFloatingBillDetails(context, billTypeModel);
                },
              ))
          .toList(),
    );
  }
}
