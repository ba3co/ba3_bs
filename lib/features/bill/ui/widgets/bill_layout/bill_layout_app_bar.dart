import 'dart:math';

import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';

AppBar billLayoutAppBar() {
  return AppBar(
    title: const Text(
      "الفواتير",
      style: TextStyle(fontWeight: FontWeight.w700),
    ),
    actions: [
      Padding(
        padding: EdgeInsets.all(8.0.r),
        child: AppButton(
          title: 'عرض جميع الفواتير',
          fontSize: 13.sp,
          onPressed: () {
            read<AllBillsController>()
              ..fetchAllBills()
              ..navigateToAllBillsScreen();
          },
          iconData: Icons.view_list_outlined,
          width: max(45.w, 140),
          // width: 40.w,
        ),
      )
    ],
  );
}
