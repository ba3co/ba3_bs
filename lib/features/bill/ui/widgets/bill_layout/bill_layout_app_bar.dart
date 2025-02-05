import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:flutter/material.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../users_management/data/models/role_model.dart';
import '../../../controllers/bill/all_bills_controller.dart';

AppBar billLayoutAppBar() {
  return AppBar(
    actions: [
      if(RoleItemType.administrator.hasReadPermission)
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
