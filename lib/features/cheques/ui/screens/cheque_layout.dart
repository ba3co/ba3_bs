import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs/features/cheques/ui/widgets/cheques_layout/cheques_layout_app_bar.dart';
import 'package:ba3_bs/core/widgets/item_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';




class ChequeLayout extends StatefulWidget {
  const ChequeLayout({super.key});

  @override
  State<ChequeLayout> createState() => _ChequeLayoutState();
}

class _ChequeLayoutState extends State<ChequeLayout> {

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GetBuilder<AllChequesController>(builder: (controller) {
        return Scaffold(
          appBar: chequesLayoutAppBar(),
          body: Column(
            children: [
              ItemWidget(text: "إضافة شيك", onTap:() {
                controller.openFloatingChequesDetails(context, ChequesType.paidChecks);
                // Get.to(() => const ChequesDetailsScreen());
              }),
              ItemWidget(text: "الشيكات المستحقة", onTap: () {
                controller
                  ..fetchAllCheques()
                  ..navigateToChequesScreen(onlyDues:true);

              }),
              ItemWidget(text: "معاينة الشيكات",onTap:  () {
                controller
                  ..fetchAllCheques()
                  ..navigateToChequesScreen(onlyDues:false);
              }),
            ],
          ),
        );
      }),
    );
  }


}
