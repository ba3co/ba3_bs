import 'package:flutter/material.dart';

import '../../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/cheques/all_cheques_controller.dart';



AppBar chequesLayoutAppBar() {
  return AppBar(
    actions: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: AppButton(
          title: 'تحميل الشيكات',
          onPressed: () => read<AllChequesController>().fetchAllChequesLocal(),
        ),
      ),
    ],
  );
}
