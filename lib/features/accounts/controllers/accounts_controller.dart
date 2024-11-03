import 'dart:developer';

import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/utils/utils.dart';
import '../../patterns/controllers/pattern_controller.dart';
import '../../patterns/ui/widgets/account_selection_dialog.dart';
import '../data/models/account_model.dart';
import '../data/repositories/accounts_repository.dart';

class AccountsController extends GetxController {
  final AccountsRepository _accountsRepository;

  AccountsController(this._accountsRepository);

  List<AccountModel> accounts = [];

  bool isLoading = true;

  Map<Account, AccountModel> selectedAccounts = {};

  AccountModel? selectedCustomerAccount;

  @override
  void onInit() {
    super.onInit();
    fetchAccounts();
  }

  // Fetch materials from the repository
  void fetchAccounts() {
    try {
      accounts = _accountsRepository.getAllAccounts();
    } catch (e) {
      debugPrint('Error in fetchAccounts($e)');
    } finally {
      isLoading = false;
      update();
    }
  }

  void navigateToAllAccountsScreen() {
    Get.toNamed(AppRoutes.showAllAccountsScreen);
  }

  List<AccountModel> searchAccountsByNameOrCode(text) {
    if (accounts.isEmpty) {
      log('Accounts isEmpty');
      fetchAccounts();
    }
    return accounts
        .where((item) => item.accName!.toLowerCase().contains(text.toLowerCase()) || item.accCode!.contains(text))
        .toList();
  }

  Map<String, AccountModel> mapAccountsByName(String query) {
    final resultMap = <String, AccountModel>{};
    for (var account in searchAccountsByNameOrCode(query)) {
      resultMap[account.accName!] = AccountModel(
        id: account.id,
        accName: account.accName,
      );
    }
    return resultMap;
  }

  String getAccountNameById(String? accountId) {
    if (accountId == null || accountId.isEmpty) return '';
    return accounts.where((account) => account.id == accountId).firstOrNull?.accName ?? '';
  }

  List<String> getAccountChildren(String? accountId) {
    if (accountId == null || accountId.isEmpty) return [];

    return accounts.where((account) => account.accParentGuid == accountId).map((child) => child.accName ?? '').toList();
  }

  Future<String?> openAccountSelectionDialog({
    required String query,
    TextEditingController? textEditingController,
    bool isCustomerAccount = false,
  }) async {
    Map<String, AccountModel> searchedAccounts = mapAccountsByName(query);

    if (searchedAccounts.isNotEmpty) {
      List<String> accountsNames = searchedAccounts.keys.toList();

      String? selectedAccountName = await Get.defaultDialog<String>(
        title: 'Choose Account',
        content: AccountSelectionDialog(accountNames: accountsNames),
      );

      if (selectedAccountName != null && textEditingController != null) {
        final AccountModel selectedAccountModel = searchedAccounts[selectedAccountName]!;

        // Infer `billTypeAccounts` from the controller
        final BillAccounts? billAccounts =
            Get.find<PatternController>().controllerToBillAccountsMap[textEditingController];

        if (billAccounts != null) {
          selectedAccounts[billAccounts] = selectedAccountModel;
        }

        // Assign selectedCustomerAccount only if the controller matches invCustomerAccountController
        if (isCustomerAccount) {
          selectedCustomerAccount = selectedAccountModel;
        }

        textEditingController.text = selectedAccountName;
        update();
      }
      return selectedAccountName;
    } else {
      Utils.showSnackBar('فحص الحسابات', 'هذا الحساب غير موجود');
      return null;
    }
  }
}
