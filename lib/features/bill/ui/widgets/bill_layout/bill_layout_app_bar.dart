import 'package:flutter/material.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bill/all_bills_controller.dart';

AppBar billLayoutAppBar() {
  return AppBar(
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppButton(
          title: 'تحميل الفواتير',
          onPressed: () => read<AllBillsController>().fetchAllBillsFromLocal(),
        ),
      ),
    ],
  );
}
