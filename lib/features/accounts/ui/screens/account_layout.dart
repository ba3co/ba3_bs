import 'package:ba3_bs/core/widgets/app_menu_item.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/Account_Option_Dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';

class AccountLayout extends StatelessWidget {
  const AccountLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الحسابات'),
/*          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                title: 'تحميل الحسابات',
                onPressed: () => read<AccountsController>().fetchAllAccountsFromLocal(),
              ),
            ),
          ],*/
        ),
        body: Column(
          children: [
            AppMenuItem(
              text: 'معاينة الحسابات',
              onTap: () {
                read<AccountsController>()
                  ..fetchAccounts()
                  ..navigateToAllAccountsScreen();
              },
            ),
            AppMenuItem(
              text: 'كشف حساب',
              onTap: () {
                showDialog<String>(context: Get.context!, builder: (BuildContext context) => accountOptionDialog(context));
              },
            ),
          ],
        ),
      ),
    );
  }
}
