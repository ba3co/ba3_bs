import 'package:ba3_bs/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs/features/bill/data/models/invoice_record_model.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../data/models/entry_bond_model.dart';
import '../../ui/screens/entry_bond_details_screen.dart';

class EntryBondController extends GetxController with FloatingLauncher {
  late EntryBondModel bondModel;

  final DataSourceRepository<EntryBondModel> _entryBondsFirebaseRepo;

  final AccountsStatementsRepository _accountsStatementsRepo;

  EntryBondController(this._entryBondsFirebaseRepo, this._accountsStatementsRepo);

  // Method to create a bond based on bill type
  void createBillBond({
    required BuildContext context,
    required BillTypeModel billTypeModel,
    required AccountModel customerAccount,
    required double total,
    required double vat,
    required double gifts,
    required double discount,
    required double addition,
  }) async {
    // _initializeBond(billTypeModel, customerAccount, total, vat, gifts, discount, addition);

    final result = await _entryBondsFirebaseRepo.save(entryBondModel, true);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) async {
        for (final item in entryBondModel.items!) {
          await _accountsStatementsRepo.addBond(item.accountId!, entryBondModel);
        }
      },
    );

    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${BillType.byLabel(billTypeModel.billTypeLabel!).value}',
      floatingScreen: const EntryBondDetailsScreen(),
    );

    //   Get.toNamed(AppRoutes.entryBondDetailsScreen);
  }

  // Handle sales invoice creation
  List<EntryBondItemModel> handleSales({
    required String billId,
    required Map<Account, AccountModel> billModelAccounts,
    required AccountModel customerAccount,
    required InvoiceRecordModel recordModel,
    required double gifts,
    required double discount,
    required double addition,
  }) {
    List<EntryBondItemModel> entryBondItems = [];

    final total = recordModel.invRecQuantity! * recordModel.invRecSubTotal!;
    final vat = recordModel.invRecQuantity! * recordModel.invRecVat!;

    final date = DateTime.now().toString().split(" ")[0];

    const creditor = BondItemType.creditor;
    const debtor = BondItemType.debtor;

    // Create a main sales bond
    if (billModelAccounts.containsKey(BillAccounts.materials)) {
      AccountModel materialsAccount = billModelAccounts[BillAccounts.materials]!;

      final materialEntryBondItem = createEntryBondItem(
        amount: total,
        billId: billId,
        bondItemType: creditor,
        accountName: materialsAccount.accName,
        accountId: materialsAccount.id,
        note: 'بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      );

      entryBondItems.add(materialEntryBondItem);
    }

    // Create bonds for cash box if applicable
    if (billModelAccounts.containsKey(BillAccounts.caches)) {
      List<EntryBondItemModel> cashBoxBuysBonds = _createCashBoxBuysBonds(
        billId: billId,
        billModelAccounts: billModelAccounts,
        customerAccount: customerAccount,
        recordModel: recordModel,
        total: total,
        date: date,
        gifts: gifts,
        vat: vat,
        discount: discount,
        addition: addition,
      );

      entryBondItems.addAll(cashBoxBuysBonds);
    }

    // Add optional bonds for sales
    List<EntryBondItemModel> addOptionalBonds = _addOptionalBonds(
        billId: billId,
        billModelAccounts: billModelAccounts,
        customerAccount: customerAccount,
        recordModel: recordModel,
        date: date,
        gifts: gifts,
        vat: vat,
        discount: discount,
        addition: addition);

    entryBondItems.addAll(addOptionalBonds);

    return entryBondItems;
  }

  List<EntryBondItemModel> _createCashBoxBuysBonds({
    required String billId,
    required Map<Account, AccountModel> billModelAccounts,
    required AccountModel customerAccount,
    required InvoiceRecordModel recordModel,
    required double total,
    required String date,
    required double gifts,
    required double vat,
    required double discount,
    required double addition,
    bool isSales = false,
  }) {
    const creditor = BondItemType.creditor;
    const debtor = BondItemType.debtor;

    return [
      if (discount > 0)
        createEntryBondItem(
          amount: discount,
          billId: billId,
          bondItemType: isSales ? creditor : debtor,
          accountName: customerAccount.accName,
          accountId: customerAccount.id,
          note: 'حسم عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
          date: date,
        ),
      if (addition > 0)
        createEntryBondItem(
          amount: addition,
          billId: billId,
          bondItemType: isSales ? debtor : creditor,
          accountName: customerAccount.accName,
          accountId: customerAccount.id,
          note: 'اضافة عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
          date: date,
        ),
      createEntryBondItem(
        amount: total,
        billId: billId,
        bondItemType: isSales ? debtor : creditor,
        accountName: customerAccount.accName,
        accountId: customerAccount.id,
        note: 'بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      ),
      createEntryBondItem(
        amount: vat,
        billId: billId,
        bondItemType: isSales ? debtor : creditor,
        accountName: customerAccount.accName,
        accountId: customerAccount.id,
        note: 'ضريبة بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      )
    ];
  }

  List<EntryBondItemModel> _addOptionalBonds({
    required String billId,
    required Map<Account, AccountModel> billModelAccounts,
    required AccountModel customerAccount,
    required InvoiceRecordModel recordModel,
    required String date,
    required double gifts,
    required double vat,
    required double discount,
    required double addition,
    bool isSales = false,
  }) {
    List<EntryBondItemModel> entryBondItems = [];

    const creditor = BondItemType.creditor;
    const debtor = BondItemType.debtor;

    if (vat > 0) {
      final vatEntryBondItem = createEntryBondItem(
        amount: vat,
        billId: billId,
        bondItemType: isSales ? creditor : debtor,
        accountName: 'ضريبة القيمة المضافة',
        accountId: 'a5c04527-63e8-4373-92e8-68d8f88bdb16',
        note: 'ضريبة بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      );
      entryBondItems.add(vatEntryBondItem);
    }

    if (gifts > 0 &&
        billModelAccounts.containsKey(BillAccounts.gifts) &&
        billModelAccounts.containsKey(BillAccounts.exchangeForGifts)) {
      AccountModel giftsAccount = billModelAccounts[BillAccounts.gifts]!;
      AccountModel settlementAccount = billModelAccounts[BillAccounts.exchangeForGifts]!;

      final giftsEntryBondItem = createEntryBondItem(
        amount: gifts,
        billId: billId,
        bondItemType: isSales ? debtor : creditor,
        accountName: giftsAccount.accName,
        accountId: giftsAccount.id,
        note: 'هدايا بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      );
      entryBondItems.add(giftsEntryBondItem);

      final settlementEntryBondItem = createEntryBondItem(
        amount: gifts,
        billId: billId,
        bondItemType: isSales ? creditor : debtor,
        accountName: settlementAccount.accName,
        accountId: settlementAccount.id,
        note: 'مقابل هدايا بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      );
      entryBondItems.add(settlementEntryBondItem);
    }

    if (discount > 0 && billModelAccounts.containsKey(BillAccounts.discounts)) {
      AccountModel discountsAccount = billModelAccounts[BillAccounts.discounts]!;

      final discountsEntryBondItem = createEntryBondItem(
        amount: discount,
        billId: billId,
        bondItemType: isSales ? debtor : creditor,
        accountName: discountsAccount.accName,
        accountId: discountsAccount.id,
        note: 'حسم بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      );
      entryBondItems.add(discountsEntryBondItem);
    }

    if (addition > 0 && billModelAccounts.containsKey(BillAccounts.additions)) {
      AccountModel additionsAccount = billModelAccounts[BillAccounts.additions]!;

      final additionsEntryBondItem = createEntryBondItem(
        amount: addition,
        billId: billId,
        bondItemType: isSales ? creditor : debtor,
        accountName: additionsAccount.accName,
        accountId: additionsAccount.id,
        note: 'اضافة بيع عدد من ${recordModel.invRecProduct}${recordModel.invRecQuantity}',
        date: date,
      );
      entryBondItems.add(additionsEntryBondItem);
    }
    return entryBondItems;
  }

  createEntryBondItem({
    required double? amount,
    required String? billId,
    required BondItemType? bondItemType,
    required String? accountName,
    required String? accountId,
    required String? note,
    required String? date,
  }) {
    return EntryBondItemModel(
      bondItemType: bondItemType,
      amount: amount,
      accountId: accountId,
      accountName: accountName,
      note: note,
      originId: billId,
      date: date,
    );
  }

//   void _initializeBond(BillTypeModel billTypeModel, AccountModel customerAccount, double total, double vat,
//       double gifts, double discount, double addition) {
//     if (billTypeModel.accounts == null) return;
//
//     BillType billType = BillType.byLabel(billTypeModel.billTypeLabel!);
//
//     switch (billType) {
//       case BillType.sales:
//         handleSales(billTypeModel.accounts!, customerAccount, total, vat, gifts, discount, addition);
//         break;
//       case BillType.purchase:
//         handleBuy(billTypeModel.accounts!, customerAccount, total, vat, gifts, discount, addition);
//         break;
//       default:
//         throw Exception('Invalid bill type');
//     }
//   }
//
//   void createEntryBond(AccountModel account, AccountModel oppositeAccount, String note) {}
//
//   // Handle sales invoice creation
//   void handleSales(Map<Account, AccountModel> billModelAccounts, AccountModel customerAccount, double total, double vat,
//       double gifts, double discount, double addition) {
//     Map<AccountModel, List<EntryBondItemModel>> bonds = {};
//
//     // Create a main sales bond
//     if (billModelAccounts.containsKey(BillAccounts.materials)) {
//       AccountModel materialsAccount = billModelAccounts[BillAccounts.materials]!;
//
//       bonds[materialsAccount] = [
//         EntryBondItemModel(
//             bondItemType: BondItemType.creditor,
//             amount: total,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: "")
//       ];
//     }
//
//     // Create bonds for cash box if applicable
//     if (billModelAccounts.containsKey(BillAccounts.caches)) {
//       // AccountModel cachesAccount = billModelAccounts[BillAccounts.caches]!;
//
//       bonds[customerAccount] = _createCashBoxSalesBonds(total, vat, discount, addition);
//     }
//
//     // Add optional bonds for sales
//     _addOptionalBonds(billModelAccounts, bonds, gifts, vat, discount, addition, isSales: true);
//
//     bondModel = EntryBondModel(bonds: bonds);
//   }
//
//   // Handle buy invoice creation
//   void handleBuy(Map<Account, AccountModel> billModelAccounts, AccountModel customerAccount, double total, double vat,
//       double gifts, double discount, double addition) {
//     Map<AccountModel, List<EntryBondItemModel>> bonds = {};
//
//     // Create a main sales bond
//     if (billModelAccounts.containsKey(BillAccounts.materials)) {
//       AccountModel materialsAccount = billModelAccounts[BillAccounts.materials]!;
//
//       bonds[materialsAccount] = [
//         EntryBondItemModel(
//             bondItemType: BondItemType.debtor,
//             amount: total,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: "")
//       ];
//     }
//
//     // Create bonds for cash box if applicable
//     if (billModelAccounts.containsKey(BillAccounts.caches)) {
//       // AccountModel cachesAccount = billModelAccounts[BillAccounts.caches]!;
//
//       bonds[customerAccount] = _createCashBoxBuysBonds(total, vat, discount, addition);
//     }
//
//     // Add optional bonds for sales
//     _addOptionalBonds(billModelAccounts, bonds, gifts, vat, discount, addition);
//
//     bondModel = EntryBondModel(bonds: bonds);
//   }
//
//   // Create bonds for the cash box for sales
//   List<EntryBondItemModel> _createCashBoxSalesBonds(double total, double vat, double discount, double addition) {
//     return [
//       // TODO: Ahmad
//       if (vat > 0)
//         EntryBondItemModel(
//             bondItemType: BondItemType.debtor,
//             amount: vat,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: ""),
//       if (discount > 0)
//         EntryBondItemModel(
//             bondItemType: BondItemType.creditor,
//             amount: discount,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: ""),
//       if (addition > 0)
//         EntryBondItemModel(
//             bondItemType: BondItemType.debtor,
//             amount: addition,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: ""),
//       EntryBondItemModel(
//           bondItemType: BondItemType.debtor,
//           amount: total,
//           account: AccountModel(),
//           oppositeAccount: AccountModel(),
//           note: ""),
//     ];
//   }
//
// // TODO: Ahmad
//   // Create bonds for the cash box for buys
//   List<EntryBondItemModel> _createCashBoxBuysBonds(double total, double vat, double discount, double addition) {
//     return [
//       if (vat > 0)
//         EntryBondItemModel(
//             bondItemType: BondItemType.creditor,
//             amount: vat,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: ""),
//       if (discount > 0)
//         EntryBondItemModel(
//             bondItemType: BondItemType.debtor,
//             amount: discount,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: ""),
//       if (addition > 0)
//         EntryBondItemModel(
//             bondItemType: BondItemType.creditor,
//             amount: addition,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: ""),
//       EntryBondItemModel(
//           bondItemType: BondItemType.creditor,
//           amount: total,
//           account: AccountModel(),
//           oppositeAccount: AccountModel(),
//           note: ""),
//     ];
//   }
//
//   // Combined method for adding optional bonds
//
//   void _addOptionalBonds(Map<Account, AccountModel> billModelAccounts,
//       Map<AccountModel, List<EntryBondItemModel>> bonds, double gifts, double vat, double discount, double addition,
//       {bool isSales = false}) {
//     if (vat > 0) {
//       // TODO: Ahmad
//       bonds[AccountModel(id: 'a5c04527-63e8-4373-92e8-68d8f88bdb16', accName: 'ضريبة القيمة المضافة')] = [
//         EntryBondItemModel(
//             bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor,
//             amount: vat,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: "")
//       ];
//     }
//
//     if (gifts > 0 &&
//         billModelAccounts.containsKey(BillAccounts.gifts) &&
//         billModelAccounts.containsKey(BillAccounts.exchangeForGifts)) {
//       AccountModel giftsAccount = billModelAccounts[BillAccounts.gifts]!;
//       AccountModel settlementAccount = billModelAccounts[BillAccounts.exchangeForGifts]!;
//       bonds[giftsAccount] = [
//         // TODO: Ahmad
//         EntryBondItemModel(
//             bondItemType: isSales ? BondItemType.debtor : BondItemType.creditor,
//             amount: gifts,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: "")
//       ];
//       // TODO: Ahmad
//       bonds[settlementAccount] = [
//         EntryBondItemModel(
//             bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor,
//             amount: gifts,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: "")
//       ];
//     }
//
//     if (discount > 0 && billModelAccounts.containsKey(BillAccounts.discounts)) {
//       AccountModel discountsAccount = billModelAccounts[BillAccounts.discounts]!;
//       bonds[discountsAccount] = [
//         // TODO: Ahmad
//         EntryBondItemModel(
//             bondItemType: isSales ? BondItemType.debtor : BondItemType.creditor,
//             amount: discount,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: "")
//       ];
//     }
//
//     if (addition > 0 && billModelAccounts.containsKey(BillAccounts.additions)) {
//       AccountModel additionsAccount = billModelAccounts[BillAccounts.additions]!;
//       bonds[additionsAccount] = [
//         // TODO: Ahmad
//         EntryBondItemModel(
//             bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor,
//             amount: addition,
//             account: AccountModel(),
//             oppositeAccount: AccountModel(),
//             note: "")
//       ];
//     }
//   }
//
// // Build DataGrid rows based on bond model
//   List<DataGridRow> buildBondDataGridRows() {
//     return bondModel.bonds.entries.expand<DataGridRow>((entry) {
//       AccountModel account = entry.key;
//       List<EntryBondItemModel> bondItems = entry.value;
//
//       return bondItems.map<DataGridRow>((bondItem) {
//         return DataGridRow(cells: [
//           DataGridCell<String>(columnName: AppConstants.rowBondAccount, value: account.accName),
//           DataGridCell<double>(
//             columnName: AppConstants.rowBondDebitAmount,
//             value: bondItem.bondItemType == BondItemType.debtor ? bondItem.amount : 0.0,
//           ),
//           DataGridCell<double>(
//             columnName: AppConstants.rowBondCreditAmount,
//             value: bondItem.bondItemType == BondItemType.creditor ? bondItem.amount : 0.0,
//           ),
//           DataGridCell<String>(columnName: AppConstants.rowBondDescription, value: '${bondItem.note}'),
//         ]);
//       });
//     }).toList();
//   }
}
