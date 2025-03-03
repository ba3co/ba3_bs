import 'dart:developer';

import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/bond/controllers/entry_bond/entry_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../../bond/ui/screens/entry_bond_details_screen.dart';
import '../data/models/account_model.dart';

class AccountStatementController extends GetxController with FloatingLauncher, AppNavigator {
  // Dependencies
  final CompoundDatasourceRepository<EntryBondItems, AccountEntity> _accountsStatementsRepo;
  final AccountsController _accountsController = read<AccountsController>();

  AccountStatementController(this._accountsStatementsRepo);

  // Text Controllers
  final productForSearchController = TextEditingController();
  final groupForSearchController = TextEditingController();
  final accountNameController = TextEditingController();
  final storeForSearchController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // Data
  final List<EntryBondItemModel> entryBondItems = [];
  List<EntryBondItemModel> filteredEntryBondItems = [];

  List<EntryBondItemModel> finalAccountsEntryBondItems = [];

  // State variables
  bool isLoading = false;

  double totalValue = 0.0;
  double debitValue = 0.0;
  double creditValue = 0.0;

  double totalFinalAccountValue = 0.0;
  double debitFinalAccountValue = 0.0;
  double creditFinalAccountValue = 0.0;

  RequestState fetchFinalAccountsStatementRequestState = RequestState.initial;

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
    startDateController.text = _formattedFirstDay;
    endDateController.text = _formattedToday;

    if (initialAccount != null) {
      accountNameController.text = initialAccount;
    } else {
      accountNameController.clear();
    }
  }

  // Event Handlers
  void onAccountNameSubmitted(String text, BuildContext context) async {
    final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);

    AccountModel? accountModel = await _accountsController.openAccountSelectionDialog(
      query: convertArabicNumbers,
      context: context,
    );
    if (accountModel != null) {
      accountNameController.text = accountModel.accName!;
    }
  }

  void onStartDateSubmitted(String text) {
    startDateController.text = AppUIUtils.getDateFromString(text);
  }

  void onEndDateSubmitted(String text) {
    endDateController.text = AppUIUtils.getDateFromString(text);
  }

  List<AccountModel> filterAccountsBySelectedFinalAccount(FinalAccounts selectedFinalAccount) {
    final accountsController = read<AccountsController>().accounts;

    List<AccountModel> accounts = [];

    // Mapping FinalAccounts to the corresponding account lists
    final Map<FinalAccounts, List<AccountModel>> accountGroups = {
      FinalAccounts.tradingAccount: accountsController.where((account) => account.accFinalGuid == FinalAccounts.tradingAccount.accPtr).toList(),
      FinalAccounts.profitAndLoss: accountsController.where((account) => account.accFinalGuid == FinalAccounts.profitAndLoss.accPtr).toList(),
      FinalAccounts.balanceSheet: accountsController.where((account) => account.accFinalGuid == FinalAccounts.balanceSheet.accPtr).toList(),
    };

    if (selectedFinalAccount == FinalAccounts.tradingAccount) {
      accounts = accountGroups[FinalAccounts.tradingAccount] ?? [];
    } else if (selectedFinalAccount == FinalAccounts.profitAndLoss) {
      accounts = [...?accountGroups[FinalAccounts.tradingAccount], ...?accountGroups[FinalAccounts.profitAndLoss]];
    } else {
      accounts = [
        ...?accountGroups[FinalAccounts.tradingAccount],
        ...?accountGroups[FinalAccounts.profitAndLoss],
        ...?accountGroups[FinalAccounts.balanceSheet]
      ];
    }

    return accounts;
  }

  Future<void> fetchFinalAccountsStatements(FinalAccounts selectedFinalAccount) async {
    //  fetchFinalAccountsStatementRequestState = RequestState.loading;
    isLoading = true;
    update();

    final finalAccounts = filterAccountsBySelectedFinalAccount(selectedFinalAccount);

    log('fetching AccountsStatement');

    final Map<AccountEntity, List<EntryBondItems>> result =
        await fetchAccountsStatement(finalAccounts.map((AccountModel acc) => AccountEntity.fromAccountModel(acc)).toList());

    finalAccountsEntryBondItems.assignAll(
      result.values
          .expand(
            (List<EntryBondItems> list) => list.expand((item) => item.itemList),
          )
          .toList(),
    );

    _calculateFinalAccountValues();

    //  fetchFinalAccountsStatementRequestState = RequestState.success;
    isLoading = false;
    update();
    log('fetchFinalAccountsStatementRequestState success');
  }

  void navigateToFinalAccountDetails() => to(AppRoutes.finalAccountDetailsScreen);

  // Fetch bond items for the selected account
  Future<void> fetchAccountEntryBondItems() async {
    final accountModel = _accountsController.getAccountModelByName(accountNameController.text);
    if (accountModel == null) {
      AppUIUtils.onFailure("يرجى إدخال اسم الحساب");
      return;
    }

    isLoading = true;
    update();

    final accountEntity = AccountEntity.fromAccountModel(accountModel);

    final result = await _accountsStatementsRepo.getAll(accountEntity);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedItems) {
        entryBondItems.assignAll(fetchedItems.expand((item) => item.itemList).toList());

        filterByDate();
        _calculateValues();
      },
    );

    isLoading = false;
    update();
  }

  Future<List<EntryBondItemModel>> fetchAccountStatement(AccountEntity accountEntity) async {
    final result = await _accountsStatementsRepo.getAll(accountEntity);

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
        return []; // Return an empty list in case of failure
      },
      (List<EntryBondItems> fetchedItems) => fetchedItems.expand((item) => item.itemList).toList(), // Return fetched items on success
    );
  }

  Future<Map<AccountEntity, List<EntryBondItems>>> fetchAccountsStatement(List<AccountEntity> accountEntities) async {
    final result = await _accountsStatementsRepo.fetchAllNested(accountEntities);

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
        return {};
      },
      (Map<AccountEntity, List<EntryBondItems>> fetchedItems) => fetchedItems,
    );
  }

  void filterByDate() {
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd'); // Format for start and end dates

    final DateTime startDate = dateFormat.parse(startDateController.text);
    final DateTime endDate = dateFormat.parse(endDateController.text);

    filteredEntryBondItems = entryBondItems.where((item) {
      final String? entryBondItemDateStr = item.date; // Ensure `date` is the correct field
      if (entryBondItemDateStr == null) return false;

      DateTime? entryBondItemDate;
      try {
        entryBondItemDate = dateFormat.parse(entryBondItemDateStr);
      } catch (e) {
        log('Error parsing item.date: $entryBondItemDateStr. Error: $e');
        return false; // Skip invalid date formats
      }

      return entryBondItemDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          entryBondItemDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Navigation handler
  void navigateToAccountStatementScreen() => to(AppRoutes.accountStatementScreen);

  void _calculateAccountValues(List<EntryBondItemModel> items,
      {required void Function(double) setTotal, required void Function(double) setDebit, required void Function(double) setCredit}) {
    if (items.isEmpty) {
      setTotal(0.0);
      setDebit(0.0);
      setCredit(0.0);
    } else {
      double debit = _calculateSum(items: items, type: BondItemType.debtor);
      double credit = _calculateSum(items: items, type: BondItemType.creditor);
      double total = debit - credit;

      setTotal(total);
      setDebit(debit);
      setCredit(credit);
    }
  }

  void _calculateFinalAccountValues() {
    _calculateAccountValues(
      finalAccountsEntryBondItems,
      setTotal: (value) => totalFinalAccountValue = value,
      setDebit: (value) => debitFinalAccountValue = value,
      setCredit: (value) => creditFinalAccountValue = value,
    );
  }

  /// Calculates debit, credit, and total values
  void _calculateValues() {
    _calculateAccountValues(
      filteredEntryBondItems,
      setTotal: (value) => totalValue = value,
      setDebit: (value) => debitValue = value,
      setCredit: (value) => creditValue = value,
    );
  }

  double _calculateSum({required List<EntryBondItemModel> items, required BondItemType type}) => items.fold(
        0.0,
        (sum, item) => item.bondItemType == type ? sum + (item.amount ?? 0.0) : sum,
      );

  String get screenTitle => 'حركات ${accountNameController.text} من تاريخ ${startDateController.text} إلى تاريخ ${endDateController.text}';

  // Helper Methods
  static String get _formattedToday => DateTime.now().dayMonthYear;

  static String get _formattedFirstDay => DateTime.now().copyWith(month: 1, day: 1).dayMonthYear;

  void launchBondEntryBondScreen({required BuildContext context, required String originId}) async {
    EntryBondModel entryBondModel = await read<EntryBondController>().getEntryBondById(entryId: originId);

    if (!context.mounted) return;
    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${entryBondModel.origin!.originType!.label}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }
}
