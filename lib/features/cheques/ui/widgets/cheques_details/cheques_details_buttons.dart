import 'package:flutter/material.dart';

import '../../../../../core/widgets/app_button.dart';

class AddChequeButtons extends StatelessWidget {
  const AddChequeButtons({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(runAlignment: WrapAlignment.center, runSpacing: 20, spacing: 20, children: [
        AppButton(
          onPressed: () async {},
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
