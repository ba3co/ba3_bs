import 'package:ba3_bs/features/cheques/ui/widgets/cheques_layout/cheques_layout_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'add_cheque.dart';
import 'all_cheques_view.dart';


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
      child: Scaffold(
        appBar:chequesLayoutAppBar(),
        body: Column(
          children: [
            Item("إضافة شيك", () {
              Get.to(() => const ChequesDetailsScreen());
            }),
            Item("الشيكات المستحقة", () {
              Get.to(() => const AllCheques(isAll: false));
            }),
            Item("معاينة الشيكات", () {
              Get.to(() => const AllCheques(isAll: true));
            }),
          ],
        ),
      ),
    );
  }

  Widget Item(text, onTap) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.all(30.0),
            child: Center(
                child: Text(
              text,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textDirection: TextDirection.rtl,
            ))),
      ),
    );
  }
}
