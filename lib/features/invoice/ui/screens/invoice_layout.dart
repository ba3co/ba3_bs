import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/router/app_routes.dart';
import '../../../login/controllers/user_management_controller.dart';
import '../../controllers/invoice_pluto_controller.dart';
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
        body: GetBuilder<InvoiceController>(builder: (invoiceController) {
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Wrap(
                    alignment: WrapAlignment.start,
                    spacing: 10.0,
                    runSpacing: 2.0,
                    children: invoiceController.billsTypes.map((bill) {
                      return InkWell(
                        onTap: () {
                          Get.find<InvoiceController>().updateBillType(bill.billTypeLabel!);
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                          ]);
                          Get.to(
                            () => InvoiceScreen(billModel: bill),
                            binding: BindingsBuilder(() {
                              Get.lazyPut(() => InvoicePlutoController());
                            }),
                          );
                        },
                        child: Container(
                          width: Get.width / 5.2,
                          margin: const EdgeInsets.all(2),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                            border: Border.all(
                              color: Color(bill.color!).withOpacity(0.5),
                              width: 1.0,
                            ),
                          ),
                          padding: const EdgeInsets.all(30.0),
                          child: Center(
                            child: Text(
                              bill.fullName ?? "error",
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              textDirection: TextDirection.rtl,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );

                      return Container(); // Return an empty container for other elements
                    }).toList()),
              ),
            ],
          );
        }),
      ),
    );
  }
}
