import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/item_widget.dart';
import '../widgets/bill_layout/bill_layout_app_bar.dart';

class BillLayout extends StatelessWidget {
  const BillLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: billLayoutAppBar(),
        body: GetBuilder<AllBillsController>(
            builder: (controller) => ListView(
                  // padding: const EdgeInsets.all(15.0),
                  children: [
                    // AllBillsTypesList(allBillsController: controller),
                    ...controller.billsTypes.map((billTypeModel) => ItemWidget(
                          text: billTypeModel.fullName!,
                          color: Color(billTypeModel.color!),
                          onTap: () {
                            controller
                              ..fetchAllBills()
                              ..openFloatingBillDetails(context, billTypeModel);
                          },
                        )),
                    const VerticalSpace(),
                    ItemWidget(
                      text: "عرض جميع الفواتير",
                      onTap: () {
                        controller
                          ..fetchAllBills()
                          ..navigateToAllBillsScreen();
                      },
                    ),
                  ],
                )),
      ),
    );
  }
}
