import 'package:ba3_bs/features/bond/controllers/bonds/all_bond_controller.dart';
import 'package:flutter/material.dart';


AppBar bondLayoutAppBar(AllBondsController controller) {
  return AppBar(actions: [
    // Padding(
    //   padding: const EdgeInsets.all(8.0),
    //   child: AppButton(
    //     title: "تحميل السندات",
    //     onPressed: () =>controller.fetchAllBondsLocal(),
    //   ),
    // ),
  ]);
}
