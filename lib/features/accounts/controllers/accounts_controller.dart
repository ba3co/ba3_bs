import 'dart:developer';

import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../../core/widgets/account_selection_dialog.dart';
import '../../bill/controllers/bill/bill_details_controller.dart';
import '../../patterns/controllers/pattern_controller.dart';
import '../data/models/account_model.dart';
import '../data/repositories/accounts_repository.dart';

class AccountsController extends GetxController {
  final AccountsRepository _accountsRepository;

  AccountsController(this._accountsRepository);

  List<AccountModel> accounts = [];



  bool isLoading = true;

  Map<Account, AccountModel> selectedAccounts = {};

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
  void navigateToAccountDetailsScreen(String accountId) {
    Get.toNamed(AppRoutes.showAccountDetailsScreen,arguments: accountId);
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
      resultMap[account.accName!] = AccountModel(id: account.id, accName: account.accName);
    }
    return resultMap;
  }

  String getAccountNameById(String? accountId) {
    if (accountId == null || accountId.isEmpty) return '';
    return accounts.where((account) => account.id == accountId).firstOrNull?.accName ?? '';
  }

  String getAccountIdByName(String? accountName) {
    if (accountName == null || accountName.isEmpty) return '';
    return accounts.where((account) => account.accName == accountName).firstOrNull?.id ?? '';
  }

  List<AccountModel> getAccounts(String query) => searchAccountsByNameOrCode(query);

  List<String> getAccountChildren(String? accountId) {
    if (accountId == null || accountId.isEmpty) return [];

    return accounts.where((account) => account.accParentGuid == accountId).map((child) => child.accName ?? '').toList();
  }

  Future<AccountModel?> openAccountSelectionDialog({
    required String query,
    TextEditingController? textEditingController,
    bool isCustomerAccount = false,
    bool fromAddBill = false,
  }) async {
    List<AccountModel> searchedAccounts = getAccounts(query);

    if (searchedAccounts.isNotEmpty) {
      AccountModel? selectedAccountModel = await Get.defaultDialog<AccountModel>(
        title: 'Choose Account',
        content: AccountSelectionDialog(accounts: searchedAccounts),
      );

      if (selectedAccountModel != null && textEditingController != null) {
        // Infer `billTypeAccounts` from the controller
        final BillAccounts? billAccounts =
            Get.find<PatternController>().controllerToBillAccountsMap[textEditingController];

        if (billAccounts != null) {
          selectedAccounts[billAccounts] = selectedAccountModel;
        }

        // Assign selectedCustomerAccount only if the controller matches customerAccountController
        if (isCustomerAccount) {
          if (fromAddBill) {
            log('fromAddBill');
            Get.find<AddBillController>().updateCustomerAccount(selectedAccountModel);
          } else {
            log('InvoiceController');
            Get.find<BillDetailsController>().updateCustomerAccount(selectedAccountModel);
          }
        }

        textEditingController.text = selectedAccountModel.accName!;
        update();
      }
      return selectedAccountModel;
    } else {
      AppUIUtils.showSnackBar(title: 'فحص الحسابات', message: 'هذا الحساب غير موجود');
      return null;
    }
  }
}
