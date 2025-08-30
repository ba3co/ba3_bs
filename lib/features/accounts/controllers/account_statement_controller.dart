import 'dart:developer';

import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/accounts/use_cases/group_accounts_by_final_category_use_case.dart';
import 'package:ba3_bs/features/bond/controllers/entry_bond/entry_bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../../bond/ui/screens/entry_bond_details_screen.dart';
import '../data/models/account_model.dart';
import '../service/account_statement_service.dart';
import '../use_cases/filter_bond_items_by_bill_type_use_case.dart';
import '../use_cases/filter_entry_bond_items_by_amount_use_case.dart';
import '../use_cases/filter_entry_bond_items_by_date_use_case.dart';
import '../use_cases/filter_entry_bond_items_by_type_use_case.dart';
import '../use_cases/merge_entry_bond_items_use_case.dart';
import '../use_cases/process_entry_bond_items_in_isolate_use_case.dart';

class AccountStatementController extends GetxController with FloatingLauncher, AppNavigator {

  // Dependencies
  final CompoundDatasourceRepository<EntryBondItems, AccountEntity>   _accountsStatementsRepo;

  final AccountsController _accountsController = read<AccountsController>();

  AccountStatementController(this._accountsStatementsRepo);

  late final AccountStatementService _accountStatementService;
  late final MergeEntryBondItemsUseCase _mergeEntryBondItemsUseCase;

  late final ProcessEntryBondItemsInIsolateUseCase processEntryBondItemsInIsolateUseCase;
  late final FilterEntryBondItemsByDateUseCase _filterEntryBondItemsByDateUseCase;

  late final FilterEntryBondItemsByAmountUseCase _filterEntryBondItemsByAmountUseCase;

  late final FilterEntryBondItemsByTypeUseCase _filterEntryBondItemsByTypeUseCase;

  late final FilterEntryBondItemsByBillTypesUseCase _filterEntryBondItemsByBillTypeUseCase;

  late final GroupAccountsByFinalCategoryUseCase _filterAccountsUseCase;

  // Text Controllers
  final productForSearchController = TextEditingController();
  final groupForSearchController = TextEditingController();
  final accountNameController = TextEditingController();
  final storeForSearchController = TextEditingController();
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();

  // to filter based on BondItemModel's amount
  final minAmountController = TextEditingController();
  final maxAmountController = TextEditingController();

  // to filter based on BondItemModel's type
  var selectedType = "".obs;

  // to filter based on  bill type (EntryBondItemModel's note)
  final RxList<String> selectedBillTypes = <String>[].obs;


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
    _initializeServices();
    resetFields();
  }

  void _initializeServices() {
    _accountStatementService = AccountStatementService();
    _mergeEntryBondItemsUseCase = MergeEntryBondItemsUseCase(_accountStatementService);
    processEntryBondItemsInIsolateUseCase = ProcessEntryBondItemsInIsolateUseCase(_accountStatementService);
    _filterEntryBondItemsByDateUseCase = FilterEntryBondItemsByDateUseCase();
    _filterAccountsUseCase = GroupAccountsByFinalCategoryUseCase();
    _filterEntryBondItemsByAmountUseCase = FilterEntryBondItemsByAmountUseCase();
    _filterEntryBondItemsByTypeUseCase = FilterEntryBondItemsByTypeUseCase();
    _filterEntryBondItemsByBillTypeUseCase = FilterEntryBondItemsByBillTypesUseCase();

  }

  /// Clears fields and resets state
  void resetFields({String? initialAccount}) {
    productForSearchController.clear();
    groupForSearchController.clear();
    storeForSearchController.clear();
    startDateController.text = _accountStatementService.formattedFirstDay;
    endDateController.text = _accountStatementService.formattedToday;

    if (initialAccount != null) {
      accountNameController.text = initialAccount;
    } else {
      accountNameController.clear();
    }
  }

  // Event Handlers
  void onAccountNameSubmitted(String text, BuildContext context) async {
    final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);

    AccountModel? accountModel =
        await _accountsController.openAccountSelectionDialog(
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

  void onMinAmountSubmitted(String text) async {
    final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);

    minAmountController.text = convertArabicNumbers;

    _validateMinMax();
  }

  void onMaxAmountSubmitted(String text) async {
    final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);

    maxAmountController.text = convertArabicNumbers;

    _validateMinMax();
  }

  void _validateMinMax() {
    final minText = minAmountController.text.trim();
    final maxText = maxAmountController.text.trim();

    if (minText.isEmpty || maxText.isEmpty) return;

    final min = double.tryParse(minText) ?? 0;
    final max = double.tryParse(maxText) ?? 0;

    // if max < min → swap
    if (max < min) {
      minAmountController.text = max.toStringAsFixed(0);
      maxAmountController.text = min.toStringAsFixed(0);
    }
  }

  void onBondItemTypeSubmitted(String? text) async {
    if(text!=null)
      {
        final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);
        selectedType.value= convertArabicNumbers;
      }
  }


  void onBillTypeAdded(String type) {
    if (!selectedBillTypes.contains(type)) {
      selectedBillTypes.add(type);
    }
    debugPrint(selectedBillTypes.toString());
  }

  void onBillTypeRemoved(String type) {
    selectedBillTypes.remove(type);
    debugPrint(selectedBillTypes.toString());
  }


  Future<void> fetchFinalAccountsStatements(
      FinalAccounts selectedFinalAccount) async {
    final accountGroups = _filterAccountsUseCase.execute();
    final tradingAccounts = accountGroups[FinalAccounts.tradingAccount] ?? [];
    final profitAndLossAccounts =
        accountGroups[FinalAccounts.profitAndLoss] ?? [];
    final balanceSheetAccounts =
        accountGroups[FinalAccounts.balanceSheet] ?? [];

    log('start', name: 'FetchFinalAccountsStatements');

    // Convert to AccountEntity format
    final tradingEntities =
        tradingAccounts.map(AccountEntity.fromAccountModel).toList();

    // Fetch trading account statements first (used in multiple cases)
    final tradingAccountResult = await fetchAccountsStatement(tradingEntities,);
    Map<AccountEntity, List<EntryBondItems>> result = {};

    if (selectedFinalAccount == FinalAccounts.tradingAccount) {
      result = tradingAccountResult;
    } else if (selectedFinalAccount == FinalAccounts.profitAndLoss) {
      result = await _fetchAndProcessProfitAndLoss(
          tradingAccountResult, profitAndLossAccounts);
    } else if (selectedFinalAccount == FinalAccounts.balanceSheet) {
      result = await _fetchAndProcessBalanceSheet(
          tradingAccountResult, profitAndLossAccounts, balanceSheetAccounts);
    }

    // Process results in an isolate for better performance
    final List<EntryBondItemModel> entryBondItems =
        await processEntryBondItemsInIsolateUseCase
            .execute(result.values.expand((list) => list).toList());
    finalAccountsEntryBondItems.assignAll(entryBondItems);

    _calculateFinalAccountValues();
    log('finish', name: 'FetchFinalAccountsStatements');
  }

  Future<Map<AccountEntity, List<EntryBondItems>>>
      _fetchAndProcessProfitAndLoss(
    Map<AccountEntity, List<EntryBondItems>> tradingAccountResult,
    List<AccountModel> profitAndLossAccounts,
  ) async {
    Map<AccountEntity, List<EntryBondItems>> result = {};

    // Merge trading account data
    final mergedTradingItem =
        _mergeEntryBondItemsUseCase.mergeTradingItems(tradingAccountResult);
    if (mergedTradingItem != null) {
      result[AccountEntity(
          id: FinalAccounts.tradingAccount.accPtr,
          name: FinalAccounts.tradingAccount.accName)] = [
        EntryBondItems(id: '', itemList: [mergedTradingItem])
      ];
    }

    // Fetch profit & loss statements
    final profitLossEntities =
        profitAndLossAccounts.map(AccountEntity.fromAccountModel).toList();
    final profitAndLossAccountResult =
        await fetchAccountsStatement(profitLossEntities,);
    result.addAll(profitAndLossAccountResult);

    return result;
  }

  Future<Map<AccountEntity, List<EntryBondItems>>> _fetchAndProcessBalanceSheet(
    Map<AccountEntity, List<EntryBondItems>> tradingAccountResult,
    List<AccountModel> profitAndLossAccounts,
    List<AccountModel> balanceSheetAccounts,
  ) async {
    // Fetch profit & loss and balance sheet statements concurrently
    final profitLossEntities =
        profitAndLossAccounts.map(AccountEntity.fromAccountModel).toList();
    final balanceSheetEntities =
        balanceSheetAccounts.map(AccountEntity.fromAccountModel).toList();

    final results = await Future.wait([
      fetchAccountsStatement(profitLossEntities,),
      fetchAccountsStatement(balanceSheetEntities,),
    ]);
    final profitAndLossAccountResult = results[0];
    final balanceSheetAccountResult = results[1];

    final mergedProfitLossItem = _mergeEntryBondItemsUseCase
        .mergeProfitLossItems(tradingAccountResult, profitAndLossAccountResult);
    if (mergedProfitLossItem != null) {
      return {
        AccountEntity(
            id: FinalAccounts.tradingAccount.accPtr,
            name: FinalAccounts.tradingAccount.accName): [
          EntryBondItems(id: '', itemList: [mergedProfitLossItem])
        ]
      }..addAll(balanceSheetAccountResult);
    }

    return balanceSheetAccountResult;
  }

  // List<AccountModel> filterAccountsBySelectedFinalAccount(FinalAccounts selectedFinalAccount) {
  //   final accountsController = read<AccountsController>().accounts;
  //
  //   List<AccountModel> accounts = [];
  //
  //   // Mapping FinalAccounts to the corresponding account lists
  //   final Map<FinalAccounts, List<AccountModel>> accountGroups = {
  //     FinalAccounts.tradingAccount: accountsController.where((account) => account.accFinalGuid == FinalAccounts.tradingAccount.accPtr).toList(),
  //     FinalAccounts.profitAndLoss: accountsController.where((account) => account.accFinalGuid == FinalAccounts.profitAndLoss.accPtr).toList(),
  //     FinalAccounts.balanceSheet: accountsController.where((account) => account.accFinalGuid == FinalAccounts.balanceSheet.accPtr).toList(),
  //   };
  //
  //   if (selectedFinalAccount == FinalAccounts.tradingAccount) {
  //     accounts = accountGroups[FinalAccounts.tradingAccount] ?? [];
  //   } else if (selectedFinalAccount == FinalAccounts.profitAndLoss) {
  //     accounts = [...?accountGroups[FinalAccounts.tradingAccount], ...?accountGroups[FinalAccounts.profitAndLoss]];
  //   } else {
  //     accounts = [
  //       ...?accountGroups[FinalAccounts.tradingAccount],
  //       ...?accountGroups[FinalAccounts.profitAndLoss],
  //       ...?accountGroups[FinalAccounts.balanceSheet]
  //     ];
  //   }
  //
  //   return accounts;
  // }
  //
  // Future<void> fetchFinalAccountsStatements(FinalAccounts selectedFinalAccount) async {
  //   final finalAccounts = filterAccountsBySelectedFinalAccount(selectedFinalAccount);
  //
  //   log('start', name: 'fetchFinalAccountsStatements');
  //
  //   final Map<AccountEntity, List<EntryBondItems>> result =
  //       await fetchAccountsStatement(finalAccounts.map((AccountModel acc) => AccountEntity.fromAccountModel(acc)).toList());
  //
  //   // Use an isolate for heavy computation
  //   final List<EntryBondItemModel> entryBondItems = await _runInIsolate(result);
  //
  //   finalAccountsEntryBondItems.assignAll(entryBondItems);
  //
  //   _calculateFinalAccountValues();
  //
  //   log('finish', name: 'fetchFinalAccountsStatements');
  // }

  // Fetch bond items for the selected account
  Future<void> fetchAccountEntryBondItems() async {

    debugPrint("Future<void> fetchAccountEntryBondItems() called");
    final accountModel = _accountsController.getAccountModelByName(accountNameController.text);

    if (accountModel == null) {
      AppUIUtils.onFailure("يرجى إدخال اسم الحساب", );
      return;
    }

    debugPrint("accountModel: ${accountModel.accName.toString()}");

    _setLoadingState(true);

    // Clear previous items before fetching new ones
    entryBondItems.clear();

    final accountEntities = _getAccountEntities(accountModel);

    debugPrint("accountEntities: ${accountEntities.length.toString()}");

    for (var account in accountEntities) {

      log(account.name, name: 'Account name');

      final result = await _accountsStatementsRepo.getAll(account);
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedItems) {
          entryBondItems.addAll(fetchedItems.expand((item) => item.itemList));
          debugPrint("fetchedItems length:${fetchedItems.length}" );
        },
      );
    }

    debugPrint("entryBondItems length:$entryBondItems");

    _filterAndCalculateValues();
    _setLoadingState(false);
  }

  void _setLoadingState(bool state) {
    isLoading = state;
    update();
  }

  List<AccountEntity> _getAccountEntities(AccountModel accountModel) {
    if (accountModel.accAccNSons == 0) {
      return [AccountEntity.fromAccountModel(accountModel)];
    }

    final accountChildren =
        _accountsController.getAccountChildren(accountModel.id);
    // log('Number of children: ${accountModel.accAccNSons}', name: 'accAccNSons');

    return accountChildren.map(AccountEntity.fromAccountModel).toList();
  }

  void _filterAndCalculateValues() {
    //filter by date
    var filtered = _filterEntryBondItemsByDateUseCase.execute(
      startDateController.text,
      endDateController.text,
      entryBondItems,
    );

    //filter by amount
    final minText = minAmountController.text.trim();
    final maxText = maxAmountController.text.trim();

    final double? min = minText.isNotEmpty ? double.tryParse(minText) : null;
    final double? max = maxText.isNotEmpty ? double.tryParse(maxText) : null;

    filtered = _filterEntryBondItemsByAmountUseCase.execute(
      minAmount: min,
      maxAmount: max,
      entryBondItems: filtered,
    );

    //filter by type
    if (selectedType.value.isNotEmpty) {
        final type = BondItemType.byLabel(selectedType.value);
        filtered = _filterEntryBondItemsByTypeUseCase.execute(type, filtered);

    }

    if(selectedBillTypes.isNotEmpty)
      {
        debugPrint("in filltering $selectedBillTypes");
        filtered = _filterEntryBondItemsByBillTypeUseCase.execute(selectedBillTypes, filtered);
      }


    filteredEntryBondItems = filtered;

    _calculateValues();
  }


  Future<double> getAccountBalance(AccountModel accountModel) async {
    double balance = 0.0;
    // Clear previous items before fetching new ones
    entryBondItems.clear();

    final accountEntities = _getAccountEntities(accountModel);

    for (var account in accountEntities) {
      // log(account.name, name: 'Account name');

      final result = await _accountsStatementsRepo.getAll(account);
      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message, ),
        (fetchedItems) {
          entryBondItems.addAll(fetchedItems.expand((item) => item.itemList));
        },
      );
    }

    _filterAndCalculateValues();
    balance = totalValue;
    return balance;
  }

  Future<List<EntryBondItemModel>> fetchAccountStatement(
      AccountEntity accountEntity,BuildContext context) async {
    debugPrint(" Future<List<EntryBondItemModel>> fetchAccountStatement called");
    final result = await _accountsStatementsRepo.getAll(accountEntity);

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message);
        return []; // Return an empty list in case of failure
      },
      (List<EntryBondItems> fetchedItems) => fetchedItems
          .expand((item) => item.itemList)
          .toList(), // Return fetched items on success
    );
  }

  Future<Map<AccountEntity, List<EntryBondItems>>> fetchAccountsStatement(

      List<AccountEntity> accountEntities) async {
    debugPrint("Future<Map<AccountEntity, List<EntryBondItems>>> fetchAccountStatement called");
    final result =
        await _accountsStatementsRepo.fetchAllNested(accountEntities);

    return result.fold(
      (failure) {
        AppUIUtils.onFailure(failure.message, );
        return {};
      },
      (Map<AccountEntity, List<EntryBondItems>> fetchedItems) => fetchedItems,
    );
  }

  /// Navigation handler
  void navigateToAccountStatementScreen() =>
      to(AppRoutes.accountStatementScreen);

  void navigateToFinalAccountDetails(FinalAccounts account) =>
      to(AppRoutes.finalAccountDetailsScreen, arguments: account);

  void _calculateAccountValues(List<EntryBondItemModel> items,
      {required void Function(double) setTotal,
      required void Function(double) setDebit,
      required void Function(double) setCredit}) {
    if (items.isEmpty) {
      setTotal(0.0);
      setDebit(0.0);
      setCredit(0.0);
    } else {
      double debit = _accountStatementService.calculateSum(
          items: items, type: BondItemType.debtor);
      double credit = _accountStatementService.calculateSum(
          items: items, type: BondItemType.creditor);
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

  String get screenTitle =>
      'حركات ${accountNameController.text} من تاريخ ${startDateController.text} إلى تاريخ ${endDateController.text}';

  // Helper Methods

  void launchBondEntryBondScreen(
      {required BuildContext context, required String originId}) async {
    EntryBondModel entryBondModel =
        await read<EntryBondController>().getEntryBondById(entryId: originId,context: context );

    if (!context.mounted) return;
    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${entryBondModel.origin!.originType!.label}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }
}