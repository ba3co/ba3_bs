import 'dart:developer';

import 'package:flutter/cupertino.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../customer/controllers/customers_controller.dart';
import '../../materials/controllers/material_controller.dart';

class CloseAccountsAndItemsUseCase {
  final bool Function(String currentVersion) migrationGuard;

  CloseAccountsAndItemsUseCase({
    required this.migrationGuard,
  });

  Future<void> execute(String currentYear, BuildContext context) async {
    if (migrationGuard(currentYear)) return;

    final accountsController = read<AccountsController>();
    final fetchedAccounts = accountsController.accounts;

    await accountsController.addAccounts(fetchedAccounts, );

    final customersController = read<CustomersController>();
    final fetchedCustomers = customersController.customers;
    if(!context.mounted)return;

    await customersController.addCustomers(fetchedCustomers,context);

    final materialAccentColor = read<MaterialController>();
    final materials = materialAccentColor.materials;
    if(!context.mounted)return;

    await materialAccentColor.saveMaterialsOnRemote(materials,context);

    log("\uD83D\uDCCC تم إغلاق الحسابات والمواد.");
  }
}