import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../accounts/data/models/account_model.dart';
import '../data/models/bond_record_model.dart';

class BondController extends GetxController {
  late EntryBondModel bondModel;

  // Method to create a bond based on bill type
  void createBillBond({required BillTypeModel billTypeModel, required AccountModel customerAccount, required double total, required double vat, required double gifts, required double discount, required double addition}) {
    _initializeBond(billTypeModel, customerAccount, total, vat, gifts, discount, addition);

    Get.toNamed(AppRoutes.entryBondDetailsView);
  }

  void _initializeBond(BillTypeModel billTypeModel, AccountModel customerAccount, double total, double vat, double gifts, double discount, double addition) {
    if (billTypeModel.accounts == null) return;

    BillType billType = BillType.byLabel(billTypeModel.billTypeLabel!);

    switch (billType) {
      case BillType.sales:
        handleSales(billTypeModel.accounts!, customerAccount, total, vat, gifts, discount, addition);
        break;
      case BillType.purchase:
        handleBuy(billTypeModel.accounts!, customerAccount, total, vat, gifts, discount, addition);
        break;
      default:
        throw Exception('Invalid bill type');
    }
  }

  void createBond(BillTypeModel billTypeModel, AccountModel account,AccountModel oppositeAccount,String note) {

  }

  // Handle sales invoice creation
  void handleSales(Map<Account, AccountModel> billModelAccounts, AccountModel customerAccount, double total, double vat, double gifts, double discount, double addition) {
    Map<AccountModel, List<BondItemModel>> bonds = {};

    // Create a main sales bond
    if (billModelAccounts.containsKey(BillAccounts.materials)) {
      AccountModel materialsAccount = billModelAccounts[BillAccounts.materials]!;

      bonds[materialsAccount] = [BondItemModel(bondItemType: BondItemType.creditor, amount: total, account: AccountModel(), oppositeAccount: AccountModel(), note: "")];
    }

    // Create bonds for cash box if applicable
    if (billModelAccounts.containsKey(BillAccounts.caches)) {
      AccountModel cachesAccount = billModelAccounts[BillAccounts.caches]!;

      bonds[customerAccount] = _createCashBoxSalesBonds(total, vat, discount, addition);
    }

    // Add optional bonds for sales
    _addOptionalBonds(billModelAccounts, bonds, gifts, vat, discount, addition, isSales: true);

    bondModel = EntryBondModel(bonds: bonds);
  }

  // Handle buy invoice creation
  void handleBuy(Map<Account, AccountModel> billModelAccounts, AccountModel customerAccount, double total, double vat, double gifts, double discount, double addition) {
    Map<AccountModel, List<BondItemModel>> bonds = {};

    // Create a main sales bond
    if (billModelAccounts.containsKey(BillAccounts.materials)) {
      AccountModel materialsAccount = billModelAccounts[BillAccounts.materials]!;

      bonds[materialsAccount] = [BondItemModel(bondItemType: BondItemType.debtor, amount: total, account: AccountModel(), oppositeAccount: AccountModel(), note: "")];
    }

    // Create bonds for cash box if applicable
    if (billModelAccounts.containsKey(BillAccounts.caches)) {
      AccountModel cachesAccount = billModelAccounts[BillAccounts.caches]!;

      bonds[customerAccount] = _createCashBoxBuysBonds(total, vat, discount, addition);
    }

    // Add optional bonds for sales
    _addOptionalBonds(billModelAccounts, bonds, gifts, vat, discount, addition);

    bondModel = EntryBondModel(bonds: bonds);
  }

  // Create bonds for the cash box for sales
  List<BondItemModel> _createCashBoxSalesBonds(double total, double vat, double discount, double addition) {
    return [
      // TODO: Ahmad
      if (vat > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: vat, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
      if (discount > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: discount, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
      if (addition > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: addition, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
      BondItemModel(bondItemType: BondItemType.debtor, amount: total, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
    ];
  }

// TODO: Ahmad
  // Create bonds for the cash box for buys
  List<BondItemModel> _createCashBoxBuysBonds(double total, double vat, double discount, double addition) {
    return [
      if (vat > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: vat, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
      if (discount > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: discount, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
      if (addition > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: addition, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
      BondItemModel(bondItemType: BondItemType.creditor, amount: total, account: AccountModel(), oppositeAccount: AccountModel(), note: ""),
    ];
  }

  // Combined method for adding optional bonds
  void _addOptionalBonds(Map<Account, AccountModel> billModelAccounts, Map<AccountModel, List<BondItemModel>> bonds, double gifts, double vat, double discount, double addition, {bool isSales = false}) {
    if (vat > 0) {
      // TODO: Ahmad
      bonds[AccountModel(id: 'a5c04527-63e8-4373-92e8-68d8f88bdb16', accName: 'ضريبة القيمة المضافة')] = [BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: vat, account: AccountModel(), oppositeAccount: AccountModel(), note: "")];
    }

    if (gifts > 0 && billModelAccounts.containsKey(BillAccounts.gifts) && billModelAccounts.containsKey(BillAccounts.exchangeForGifts)) {
      AccountModel giftsAccount = billModelAccounts[BillAccounts.gifts]!;
      AccountModel settlementAccount = billModelAccounts[BillAccounts.exchangeForGifts]!;
      bonds[giftsAccount] = [
        // TODO: Ahmad
        BondItemModel(bondItemType: isSales ? BondItemType.debtor : BondItemType.creditor, amount: gifts, account: AccountModel(), oppositeAccount: AccountModel(), note: "")
      ];
      // TODO: Ahmad
      bonds[settlementAccount] = [BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: gifts, account: AccountModel(), oppositeAccount: AccountModel(), note: "")];
    }

    if (discount > 0 && billModelAccounts.containsKey(BillAccounts.discounts)) {
      AccountModel discountsAccount = billModelAccounts[BillAccounts.discounts]!;
      bonds[discountsAccount] = [
        // TODO: Ahmad
        BondItemModel(bondItemType: isSales ? BondItemType.debtor : BondItemType.creditor, amount: discount, account: AccountModel(), oppositeAccount: AccountModel(), note: "")
      ];
    }

    if (addition > 0 && billModelAccounts.containsKey(BillAccounts.additions)) {
      AccountModel additionsAccount = billModelAccounts[BillAccounts.additions]!;
      bonds[additionsAccount] = [
        // TODO: Ahmad
        BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: addition, account: AccountModel(), oppositeAccount: AccountModel(), note: "")
      ];
    }
  }

// Build DataGrid rows based on bond model
  List<DataGridRow> buildBondDataGridRows() {
    return bondModel.bonds.entries.expand<DataGridRow>((entry) {
      AccountModel account = entry.key;
      List<BondItemModel> bondItems = entry.value;

      return bondItems.map<DataGridRow>((bondItem) {
        return DataGridRow(cells: [
          DataGridCell<String>(columnName: AppConstants.rowBondAccount, value: account.accName),
          DataGridCell<double>(
            columnName: AppConstants.rowBondDebitAmount,
            value: bondItem.bondItemType == BondItemType.debtor ? bondItem.amount : 0.0,
          ),
          DataGridCell<double>(
            columnName: AppConstants.rowBondCreditAmount,
            value: bondItem.bondItemType == BondItemType.creditor ? bondItem.amount : 0.0,
          ),
          DataGridCell<String>(columnName: AppConstants.rowBondDescription, value: '${account.note}'),
        ]);
      });
    }).toList();
  }
}
