import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/cheques_details_controller.dart';
import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';

class AddChequeButtons extends StatelessWidget {
  const AddChequeButtons({
    super.key, required this.chequesDetailsController, required this.chequesType,

  });
final ChequesDetailsController chequesDetailsController;
final ChequesType chequesType;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(runAlignment: WrapAlignment.center, runSpacing: 20, spacing: 20, children: [
        AppButton(
          onPressed: () async {
            chequesDetailsController.saveCheques(chequesType);


          },
          title: "إضافة",
          iconData: Icons.add,
        ),
        AppButton(
          onPressed: () {},
          title: "حذف",
          iconData: Icons.delete_outline,
          color: Colors.red,
        ),
        AppButton(
          onPressed: () {},
          title: "السند",
          iconData: Icons.view_list_outlined,
        ),
        AppButton(
          onPressed: () async {},
          title: "دفع",
          color: Colors.black,
          iconData: Icons.paid,
        ),
        AppButton(
          onPressed: () {},
          title: "سند الدفع",
          iconData: Icons.view_list_outlined,
        ),
      ]),
    );
  }
}
