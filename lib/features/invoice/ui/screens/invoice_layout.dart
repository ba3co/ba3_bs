import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../login/controllers/user_management_controller.dart';
import '../../controllers/invoice_pluto_controller.dart';
import '../widgets/bill_item_widget.dart';
import 'invoice_screen.dart';

class InvoiceLayout extends StatelessWidget {
  const InvoiceLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            children: [
              const Text(
                "الفواتير",
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              Text(
                Get.find<UserManagementController>().myUserModel?.userName ?? "",
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ],
          ),
          actions: [
            IconButton(
                onPressed: () {
                  Get.find<UserManagementController>().userStatus = UserManagementStatus.first;
                  Get.offAllNamed(AppRoutes.loginScreen);
                },
                icon: const Icon(Icons.logout, color: Colors.red))
          ],
        ),
        body: GetBuilder<InvoiceController>(
            builder: (invoiceController) => ListView(
                  padding: const EdgeInsets.all(15.0),
                  children: [
                    Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 10.0,
                      runSpacing: 2.0,
                      children: invoiceController.billsTypes
                          .map((bill) => BillItemWidget(
                                bill: bill,
                                invoiceController: invoiceController,
                                onPressed: () {
                                  invoiceController.initCustomerAccount(bill.accounts?[BillAccounts.caches]);
                                  SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
                                  Get.to(
                                    () => InvoiceScreen(billModel: bill),
                                    binding: BindingsBuilder(() {
                                      Get.lazyPut(() => InvoicePlutoController());
                                    }),
                                  );
                                },
                              ))
                          .toList(),
                    ),
                  ],
                )),
      ),
    );
  }
}
