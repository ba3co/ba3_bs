import 'dart:developer';

import 'package:ba3_bs/core/constants/app_config.dart';
import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/bill/data/models/invoice_record_model.dart';
import 'package:ba3_bs/features/bond/data/models/entry_bond_model.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../../core/network/api_constants.dart';
import '../../../core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../accounts/data/models/account_model.dart';
import '../../bill/data/models/bill_items.dart';
import '../../bond/data/models/bond_model.dart';
import '../../bond/data/models/pay_item_model.dart';
import '../../bond/service/bond/floating_bond_details_launcher.dart';
import '../../materials/controllers/material_controller.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../use_cases/generate_bill_records_use_case.dart';

class MigrationController extends FloatingBondDetailsLauncher with EntryBondsGenerator, FirestoreSequentialNumbers {
  final CompoundDatasourceRepository<BondModel, BondType> _bondsFirebaseRepo;
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;

  MigrationController(this._bondsFirebaseRepo, this._billsFirebaseRepo);

  RxBool isMigrating = false.obs;
  RxString migrationStatus = ''.obs;

  late final GenerateBillRecordsUseCase _generateBillRecordsUseCase;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    if (migrationVersions.isNotEmpty) {
      selectedVersion.value = migrationVersions.first;
    }
  }

  void _initializeServices() {
    _generateBillRecordsUseCase = GenerateBillRecordsUseCase();
  }

  // 🔹 Available migration versions
  var migrationVersions = [
    DateTime.now().year.toString(), // Current year
    (DateTime.now().year + 1).toString(), // Next year
  ].obs;

  // 🔹 Selected migration version (initialized to the first version)
  var selectedVersion = ''.obs;

  String get currentVersion {
    if (selectedVersion.value == DateTime.now().year.toString()) {
      return '';
    }
    return selectedVersion.value;
  }

  void setMigrationVersion(String version) {
    selectedVersion.value = version;
  }

  Future<void> startMigration() async {
    log(AppConfig.instance.year, name: 'AppConfig.year');

    isMigrating.value = true;
    migrationStatus.value = 'جارٍ تنفيذ الترحيل...';

    final currentYear = AppConfig.instance.year;

    try {
      AppConfig.instance.changeYear('2025_');

      log(AppConfig.instance.year, name: 'AppConfig.year');

      // // تدوير الأرصدة: كل حساب يتم نقل أرصدته للسنة الجديدة كمفتتح
      //await rotateBalances(currentYear);

      // نسخ نهاية المدة: كل المواد يتم نقل كميتها الختامية للسنة الجديدة
      await copyEndPeriod(currentYear);

      // التحقق من الإدخالات غير المصروفة
      await checkUnprocessedEntries(currentYear);

      // إغلاق الحساب والمواد
      await closeAccountsAndItems(currentYear);

      migrationStatus.value = "✅ تم الترحيل بنجاح!";
    } catch (e, stackTrace) {
      migrationStatus.value = "⚠️ فشل الترحيل: $e";

      log(e.toString(), name: "catch", stackTrace: stackTrace);
    } finally {
      isMigrating.value = false;

      AppConfig.instance.changeYear('');

      log(AppConfig.instance.year, name: "finally");
    }
  }

  // 1:32
  // 5436

  Future<void> rotateBalances(String currentYear) async {
    if (guardedCall(currentYear)) {
      log('true', name: 'rotateBalances guardedCall');
      return;
    }

    //final accounts = read<AccountsController>().accounts.where((acc) => acc.accType == 1).toList();

    final accountEntities = read<AccountsController>().accounts.map(AccountEntity.fromAccountModel).toList();

    final accountStatementController = read<AccountStatementController>();

    log("${accountEntities.length} عدد الحسابات", name: "MigrationController.rotateBalances");

    final allAccountsStatement = await accountStatementController.fetchAccountsStatement(accountEntities);

    final entryBondItems =
        await accountStatementController.processEntryBondItemsInIsolateUseCase.execute(allAccountsStatement.values.expand((list) => list).toList());

    final totalDebit = entryBondItems.fold(
      0.0,
      (previousValue, element) => previousValue + (element.bondItemType == BondItemType.debtor ? element.amount! : 0),
    );

    final totalCredit = entryBondItems.fold(
      0.0,
      (previousValue, element) => previousValue + (element.bondItemType == BondItemType.creditor ? element.amount! : 0),
    );

    log('totalDebit: $totalDebit - totalCredit: $totalCredit', name: 'Debit & Credit');

    final isDebitCreditEquals = checkDebitCreditEquals(totalDebit, totalCredit);

    if (!isDebitCreditEquals) {
      AppUIUtils.onFailure('الحسابات ليست متساوية');
      log("الحسابات ليست متساوية", name: "MigrationController.rotateBalances");
      return;
    }

    await saveBond(
      bondModel: BondModel.fromBondData(
        bondType: BondType.openingEntry,
        note: 'قيد إفتتاحي خاص بترحيل الأرصدة للسنة الجديدة',
        payDate: DateTime.now().toIso8601String(),
        bondRecordsItems: generatePayItems(entryBondItems),
      ),
    );

    log("📌 تم تدوير الأرصدة بنجاح.");
  }

  Future<void> saveBond({required BondModel bondModel}) async {
    final result = await _bondsFirebaseRepo.save(bondModel);

    await result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedBond) async => await handleSaveBondSuccess(savedBond),
    );
  }

  Future<void> handleSaveBondSuccess(BondModel bond) async {
    await createAndStoreEntryBond(model: bond);
  }

  List<PayItem> generatePayItems(List<EntryBondItemModel> entryBondItems) {
    final payItems = entryBondItems
        .map(
          (EntryBondItemModel item) => PayItem(
            entryCredit: item.bondItemType == BondItemType.creditor ? item.amount : 0,
            entryDebit: item.bondItemType == BondItemType.debtor ? item.amount : 0,
            entryAccountGuid: item.account.id,
            entryAccountName: item.account.name,
            entryDate: item.date,
            entryNote: item.note,
          ),
        )
        .toList();

    return payItems;
  }

  bool guardedCall(String currentYear) {
    if (AppConfig.instance.year == currentYear) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> copyEndPeriod(String currentYear) async {
    if (guardedCall(currentYear)) {
      log('true $currentYear', name: 'copyEndPeriod guardedCall');
      return;
    }

    final billTypeModel = BillType.firstPeriodInventory.billTypeModel;
    final materials = read<MaterialController>().materials;

    // ✅ Now, all GetX-related calls happen before spawning the isolate
    List<InvoiceRecordModel> billRecords = await _generateBillRecordsUseCase.execute(materials);

    double billTotal = billRecords.fold(0, (sum, record) => sum + (record.invRecTotal ?? 0));

    List<BillModel> bills = [];

    final billModel = BillModel.fromBillData(
      status: Status.approved,
      billPayType: InvPayType.cash.index,
      billDate: DateTime.now(),
      billCustomerId: '',
      billSellerId: '',
      billGiftsTotal: 0,
      billDiscountsTotal: 0,
      billAdditionsTotal: 0,
      billVatTotal: 0,
      billFirstPay: 0,
      billTotal: billTotal,
      billWithoutVatTotal: billTotal,
      billTypeModel: billTypeModel,
      billRecords: billRecords,
    );

    final entitySequence =
        await fetchAndIncrementEntityNumber('${AppConfig.instance.year}${ApiConstants.bills}', BillType.firstPeriodInventory.label);

    final updatedBill = billModel.copyWith(billDetails: billModel.billDetails.copyWith(billNumber: entitySequence.nextNumber));

    final chunks = _splitItemsIntoChunks(updatedBill.items.itemList, AppConstants.maxItemsPerBill);

    if (chunks.length > 1) {
      final List<BillModel> splitBills = _divideLargeBill(updatedBill, maxItemsPerBill: AppConstants.maxItemsPerBill);
      bills.addAll(splitBills);
    } else {
      bills.add(updatedBill);
    }

    for (int i = 0; i < bills.length; i++) {
      await saveBill(billModel: bills[i]);
    }

    await setLastUsedNumber(
      '${AppConfig.instance.year}${ApiConstants.bills}',
      BillType.firstPeriodInventory.label,
      bills.last.billDetails.billNumber!,
    );

    log("📌 End of year inventory quantities transferred. Total invoice: $billTotal");
  }

  List<List<dynamic>> _splitItemsIntoChunks(List items, int maxItemsPerBill) => items.chunkBy((maxItemsPerBill));

  /// Splits a large bill into multiple smaller bills, each having at most `maxItemsPerBill` items.
  List<BillModel> _divideLargeBill(BillModel bill, {required int maxItemsPerBill}) {
    final List<BillModel> splitBills = [];
    final items = bill.items.itemList;
    final chunks = items.chunkBy((maxItemsPerBill));

    for (int i = 0; i < chunks.length; i++) {
      final newBill = bill.copyWith(
        // Assign new unique ID
        billId: "${BillType.firstPeriodInventory.label}_part${i + 1}",
        billDetails: bill.billDetails.copyWith(billNumber: bill.billDetails.billNumber! + i),
        items: BillItems(itemList: chunks[i]),
      );

      splitBills.add(newBill);
    }

    return splitBills;
  }

  Future<void> saveBill({required BillModel billModel}) async {
    final result = await _billsFirebaseRepo.save(billModel);

    await result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedBill) async => await handleSaveBillSuccess(savedBill),
    );
  }

  Future<void> handleSaveBillSuccess(BillModel bill) async {}

  Future<void> checkUnprocessedEntries(String currentYear) async {
    log("📌 التحقق من الإدخالات غير المصروفة.");
  }

  Future<void> closeAccountsAndItems(String currentYear) async {
    log("📌 تم إغلاق الحسابات والمواد.");
  }

  bool checkDebitCreditEquals(double a, double b) => (a - b).abs() <= 1;
}
