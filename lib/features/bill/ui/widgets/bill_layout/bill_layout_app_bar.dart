
import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bill/all_bills_controller.dart';


AppBar billLayoutAppBar(AllBillsController controller) {
  return AppBar(
    // title: const Text(
    //   "الفواتير و انماط البيع",
    //   style: TextStyle(fontWeight: FontWeight.w700),
    // ),
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppButton(
          title: "تحميل الفواتير",
          onPressed: () =>controller.fetchAllBillsFromLocal(),
        ),
      ),
    ],
  );
}
