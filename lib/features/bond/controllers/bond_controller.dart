import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../../accounts/data/models/account_model.dart';
import '../data/models/bond_record_model.dart';

class BondController extends GetxController {
  late BondModel bondModel;

  // Method to create a bond based on bill type
  void createBond(
      {required Map<Account, AccountModel> billTypeModelAccounts,
      required BillType billType,
      AccountModel? customerAccount,
      required double total,
      required double vat,
      required double gifts,
      required double discount,
      required double addition}) {
    _initializeBond(billTypeModelAccounts, billType, customerAccount, total, vat, gifts, discount, addition);

    Get.toNamed(AppRoutes.entryBondDetailsView);
  }

  void _initializeBond(Map<Account, AccountModel> billTypeModelAccounts, BillType billType,
      AccountModel? customerAccount, double total, double vat, double gifts, double discount, double addition) {
    switch (billType) {
      case BillType.sales:
        handleSales(billTypeModelAccounts, customerAccount, total, vat, gifts, discount, addition);
        break;
      case BillType.buy:
        handleBuy(billTypeModelAccounts, customerAccount, total, vat, gifts, discount, addition);
        break;
      default:
        throw Exception('Invalid bill type');
    }
  }

  // Handle sales invoice creation
  void handleSales(Map<Account, AccountModel> billTypeModelAccounts, AccountModel? customerAccount, double total,
      double vat, double gifts, double discount, double addition) {
    Map<AccountModel, List<BondItemModel>> bonds = {};

    // Create a main sales bond
    if (billTypeModelAccounts.containsKey(BillTypeAccounts.materials)) {
      AccountModel materialsAccount = billTypeModelAccounts[BillTypeAccounts.materials]!;

      bonds[materialsAccount] = [BondItemModel(bondItemType: BondItemType.creditor, amount: total)];
    }

    // Create bonds for cash box if applicable
    if (billTypeModelAccounts.containsKey(BillTypeAccounts.caches)) {
      AccountModel cachesAccount = billTypeModelAccounts[BillTypeAccounts.caches]!;

      bonds[customerAccount ?? cachesAccount] = _createCashBoxSalesBonds(total, vat, discount, addition);
    }

    // Add optional bonds for sales
    _addOptionalBonds(billTypeModelAccounts, bonds, gifts, vat, discount, addition, isSales: true);

    bondModel = BondModel(bonds: bonds);
  }

  // Handle buy invoice creation
  void handleBuy(Map<Account, AccountModel> billTypeModelAccounts, AccountModel? customerAccount, double total,
      double vat, double gifts, double discount, double addition) {
    // Map<Account, List<BondItemModel>> bonds = {};
    //
    // // Create a main purchase bond
    // bonds[BuyAccounts.purchases] = [BondItemModel(bondItemType: BondItemType.debtor, amount: total)];
    //
    // // Create bonds for cash box if applicable
    // bonds[customerAccount] = _createCashBoxBuysBonds(total, vat, discount, addition);
    //
    // // Add optional bonds for buys
    // _addOptionalBonds(billTypeModelAccounts, bonds, gifts, vat, discount, addition, isSales: false);
    //
    // bondModel = BondModel(bonds: bonds);
  }

  // Create bonds for the cash box for sales
  List<BondItemModel> _createCashBoxSalesBonds(double total, double vat, double discount, double addition) {
    return [
      if (vat > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: vat),
      if (discount > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: discount),
      if (addition > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: addition),
      BondItemModel(bondItemType: BondItemType.debtor, amount: total),
    ];
  }

  // Create bonds for the cash box for buys
  List<BondItemModel> _createCashBoxBuysBonds(double total, double vat, double discount, double addition) {
    return [
      if (vat > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: vat),
      if (discount > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: discount),
      if (addition > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: addition),
      BondItemModel(bondItemType: BondItemType.creditor, amount: total),
    ];
  }

  // Combined method for adding optional bonds
  void _addOptionalBonds(Map<Account, AccountModel> billTypeModelAccounts, Map<AccountModel, List<BondItemModel>> bonds,
      double gifts, double vat, double discount, double addition,
      {required bool isSales}) {
    if (vat > 0) {
      bonds[AccountModel(id: 'a5c04527-63e8-4373-92e8-68d8f88bdb16', accName: 'ضريبة القيمة المضافة')] = [
        BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: vat)
      ];
    }

    if (gifts > 0 &&
        billTypeModelAccounts.containsKey(BillTypeAccounts.gifts) &&
        billTypeModelAccounts.containsKey(BillTypeAccounts.exchangeForGifts)) {
      AccountModel giftsAccount = billTypeModelAccounts[BillTypeAccounts.gifts]!;
      AccountModel settlementAccount = billTypeModelAccounts[BillTypeAccounts.exchangeForGifts]!;
      bonds[giftsAccount] = [
        BondItemModel(bondItemType: isSales ? BondItemType.debtor : BondItemType.creditor, amount: gifts)
      ];
      bonds[settlementAccount] = [
        BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: gifts)
      ];
    }

    if (discount > 0 && billTypeModelAccounts.containsKey(BillTypeAccounts.discounts)) {
      AccountModel discountsAccount = billTypeModelAccounts[BillTypeAccounts.discounts]!;
      bonds[discountsAccount] = [BondItemModel(bondItemType: BondItemType.debtor, amount: discount)];
    }

    if (addition > 0 && billTypeModelAccounts.containsKey(BillTypeAccounts.additions)) {
      AccountModel additionsAccount = billTypeModelAccounts[BillTypeAccounts.additions]!;
      bonds[additionsAccount] = [
        BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: addition)
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
          DataGridCell<String>(columnName: AppConstants.rowBondDescription, value: "Bond for ${account.toString()}"),
        ]);
      });
    }).toList();
  }
}
