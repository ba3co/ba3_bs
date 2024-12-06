import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/bill_layout/all_bills_types_list.dart';
import '../widgets/bill_layout/bill_layout_app_bar.dart';
import '../widgets/bill_layout/display_all_billIs_button.dart.dart';

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
                  padding: const EdgeInsets.all(15.0),
                  children: [
                    AllBillsTypesList(allBillsController: controller),
                    const VerticalSpace(20),
                    DisplayAllBillsButton(
                      onTap: () {
                        controller
                          ..fetchBills()
                          ..navigateToAllBillsScreen();
                      },
                    ),
                  ],
                )),
      ),
    );
  }
}
