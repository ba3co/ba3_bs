import 'dart:developer';

import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../bond/data/models/entry_bond_model.dart';
import '../data/datasources/remote/accounts_statements_data_source.dart';

class AccountStatementController extends GetxController {
  // Dependencies
  final AccountsStatementsRepository _accountsStatementsRepo;
  final AccountsController _accountsController = Get.find<AccountsController>();

  AccountStatementController(this._accountsStatementsRepo);

  // Text Controllers
  final productForSearchController = TextEditingController();
  final groupForSearchController = TextEditingController();
  final accountNameController = TextEditingController();
  final storeForSearchController = TextEditingController();
  final startDateController = TextEditingController()..text = _formattedToday;
  final endDateController = TextEditingController()..text = _formattedToday;

  // Data
  final List<EntryBondItemModel> entryBondItems = [];

  // State variables
  bool isLoading = true;

  double totalValue = 0.0;
  double debitValue = 0.0;
  double creditValue = 0.0;

  @override
  void onInit() {
    super.onInit();
    resetFields();
  }

  /// Clears fields and resets state
  void resetFields({String? initialAccount}) {
    productForSearchController.clear();
    groupForSearchController.clear();
    storeForSearchController.clear();
    startDateController.text = _formattedToday;
    endDateController.text = _formattedToday;

    if (initialAccount != null) {
      accountNameController.text = initialAccount;
    } else {
      accountNameController.clear();
    }
  }

  // Event Handlers
  void onAccountNameSubmitted(String text, BuildContext context) {
    _accountsController.openAccountSelectionDialog(
      query: text,
      context: context,
      textEditingController: accountNameController,
    );
    update();
  }

  void onStartDateSubmitted(String text) {
    startDateController.text = AppUIUtils.getDateFromString(text);
    update();
  }

  void onEndDateSubmitted(String text) {
    endDateController.text = AppUIUtils.getDateFromString(text);
    update();
  }

  // Fetch bond items for the selected account
  Future<void> fetchAccountEntryBondItems() async {
    final accountModel = _accountsController.getAccountModelByName(accountNameController.text);
    if (accountModel == null) {
      _showErrorSnackBar("خطأ إدخال", "يرجى إدخال اسم الحساب");
      return;
    }

    final result = await _accountsStatementsRepo.getAllBonds(accountModel.id!);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedItems) {
        entryBondItems.assignAll(fetchedItems);
        _calculateValues();
      },
    );

    isLoading = false;
    update();
  }

  List<EntryBondItemModel> filterByDate() {
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy'); // Match your date format

    final DateTime startDate = dateFormat.parse(startDateController.text);
    final DateTime endDate = dateFormat.parse(endDateController.text);

    return entryBondItems.where((item) {
      final String? entryBondItemDateStr = item.date; // Ensure `date` is the correct field
      //  final String? entryBondItemDateStr = '2024-12-15'; // Ensure `date` is the correct field
      if (entryBondItemDateStr == null) return false;

      DateTime? entryBondItemDate;
      try {
        entryBondItemDate = dateFormat.parse(entryBondItemDateStr);
      } catch (e) {
        log('e $e ');
        return false; // Skip invalid date formats
      }

      return entryBondItemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entryBondItemDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Navigation handler
  void navigateToAccountStatementScreen() {
    Get.toNamed(AppRoutes.accountStatementScreen);
  }

  /// Calculates debit, credit, and total values
  void _calculateValues() {
    debitValue = _calculateSum(BondItemType.debtor);
    creditValue = _calculateSum(BondItemType.creditor);

    totalValue = debitValue - creditValue;
  }

  double _calculateSum(BondItemType type) {
    return entryBondItems.fold(0.0, (sum, item) {
      return item.bondItemType == type ? sum + (item.amount ?? 0.0) : sum;
    });
  }

  String get screenTitle =>
      'حركات ${accountNameController.text} من تاريخ ${startDateController.text} إلى تاريخ ${endDateController.text}';

  // Helper Methods
  static String get _formattedToday => DateTime.now().toString().split(" ")[0];

  void _showErrorSnackBar(String title, String message) {
    Get.snackbar(title, message, icon: const Icon(Icons.error_outline));
  }
}
