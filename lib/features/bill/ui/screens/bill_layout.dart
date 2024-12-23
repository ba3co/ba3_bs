import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../widgets/bill_layout/bill_layout_app_bar.dart';
import '../widgets/bill_layout/bill_type_item_widget.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: billLayoutAppBar(),
        body: GetBuilder<AllBillsController>(
            builder: (controller) => Container(
              width: 1.sw,
              padding: const EdgeInsets.all(10.0),
              child: Column(

                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 5,
                        runSpacing: 10,
                        alignment: WrapAlignment.start,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          ...controller.billsTypes.map((billTypeModel) => BillITypeItemWidget(
                                text: billTypeModel.fullName!,
                                color: Color(billTypeModel.color!),
                                onTap: () {
                                  controller
                                    ..fetchAllBills()
                                    ..openFloatingBillDetails(context, billTypeModel);
                                },
                              )),
                        ],
                      ),

                    ],
                  ),
            )),
      ),
    );
  }
}
