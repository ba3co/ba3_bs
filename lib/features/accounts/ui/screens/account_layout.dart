import 'package:ba3_bs/core/widgets/app_menu_item.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountLayout extends StatelessWidget {
  const AccountLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الحسابات')),
        body: Column(
          children: [
            AppMenuItem(
              text: 'معاينة الحسابات',
              onTap: () {
                Get.find<AccountsController>()
                  ..fetchAccounts()
                  ..navigateToAllAccountsScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
}
