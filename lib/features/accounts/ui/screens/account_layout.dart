import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/app_menu_item.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/customer/controllers/customers_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/dialogs/Account_Option_Dialog.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/widgets/app_button.dart';

class AccountLayout extends StatelessWidget {
  const AccountLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title:  Text(AppStrings().accounts),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                title:AppStrings().downloadAccounts,
                onPressed: () => read<AccountsController>().fetchAllAccountsFromLocal(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppButton(
                title:AppStrings().downloadCustomers,
                onPressed: () => read<CustomersController>().fetchAllCustomersFromLocal(),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            AppMenuItem(
              text:AppStrings().viewAccounts,
              onTap: () {
                read<AccountsController>()
                  ..fetchAccounts()
                  ..navigateToAllAccountsScreen();
              },
            ),
            AppMenuItem(
              text: AppStrings().accountStatement,
              onTap: () {
                showDialog<String>(
                    context: Get.context!, builder: (BuildContext context) => accountOptionDialog(context));
              },
            ),
            AppMenuItem(
              text: AppStrings().addAccount,
              onTap: () {
                read<AccountsController>().navigateToAddOrUpdateAccountScreen();
              },
            ),
          ],
        ),
      ),
    );
  }
}
