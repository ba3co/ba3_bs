import 'dart:developer';

import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../data/models/account_model.dart';
import '../data/repositories/accounts_repository.dart';

class AccountsController extends GetxController {
  final AccountsRepository _accountsRepository;

  AccountsController(this._accountsRepository);

  List<AccountModel> accounts = [];

  bool isLoading = true;

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

  List<AccountModel> searchAccountsByName(text) {
    if (accounts.isEmpty) {
      log('Accounts isEmpty');
      fetchAccounts();
    }
    return accounts.where((item) => item.accName!.toLowerCase().contains(text.toLowerCase())).toList();
  }

  List<String> getAccountsNames(query) => searchAccountsByName(query).map((account) => account.accName!).toList();

  String getAccountNameById(String? accountId) {
    if (accountId == null || accountId.isEmpty) return '';
    return accounts.where((account) => account.id == accountId).firstOrNull?.accName ?? '';
  }

  List<String> getAccountChildren(String? accountId) {
    if (accountId == null || accountId.isEmpty) return [];

    return accounts.where((account) => account.accParentGuid == accountId).map((child) => child.accName ?? '').toList();
  }
}
