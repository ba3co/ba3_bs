import 'package:ba3_bs/core/router/app_routes.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../data/models/bond_record_model.dart';

class BondController extends GetxController {
  late BondModel bondModel;

  // Method to create a bond based on bill type
  void createBond(
      {required BillType billType,
      required CustomerAccount customerAccount,
      required double total,
      required double vat,
      required double gifts,
      required double discount,
      required double addition}) {
    _initializeBond(billType, customerAccount, total, vat, gifts, discount, addition);

    Get.toNamed(AppRoutes.entryBondDetailsView);
  }

  void _initializeBond(BillType billType, CustomerAccount customerAccount, double total, double vat, double gifts, double discount, double addition) {
    switch (billType) {
      case BillType.sales:
        handleSales(customerAccount, total, vat, gifts, discount, addition);
        break;
      case BillType.buy:
        handleBuy(customerAccount, total, vat, gifts, discount, addition);
        break;
      default:
        throw Exception('Invalid bill type');
    }
  }

  // Handle sales invoice creation
  void handleSales(CustomerAccount customerAccount, double total, double vat, double gifts, double discount, double addition) {
    Map<Account, List<BondItemModel>> bonds = {};

    // Create a main sales bond
    bonds[SalesAccounts.sales] = [BondItemModel(bondItemType: BondItemType.creditor, amount: total)];

    // Create bonds for cash box if applicable
    bonds[customerAccount] = _createCashBoxSalesBonds(total, vat, discount, addition);

    // Add optional bonds for sales
    _addOptionalBonds(bonds, gifts, vat, discount, addition, isSales: true);

    bondModel = BondModel(bonds: bonds);
  }

  // Handle buy invoice creation
  void handleBuy(CustomerAccount customerAccount, double total, double vat, double gifts, double discount, double addition) {
    Map<Account, List<BondItemModel>> bonds = {};

    // Create a main purchase bond
    bonds[BuyAccounts.purchases] = [BondItemModel(bondItemType: BondItemType.debtor, amount: total)];

    // Create bonds for cash box if applicable
    bonds[customerAccount] = _createCashBoxBuysBonds(total, vat, discount, addition);

    // Add optional bonds for buys
    _addOptionalBonds(bonds, gifts, vat, discount, addition, isSales: false);

    bondModel = BondModel(bonds: bonds);
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
  void _addOptionalBonds(Map<Account, List<BondItemModel>> bonds, double gifts, double vat, double discount, double addition,
      {required bool isSales}) {
    final Account vatAccount = isSales ? SalesAccounts.vat : BuyAccounts.vat;
    final Account giftsAccount = isSales ? SalesAccounts.salesGifts : BuyAccounts.purchaseGifts;
    final Account settlementAccount = isSales ? SalesAccounts.settlements : BuyAccounts.settlements;
    final Account discountAccount = isSales ? SalesAccounts.grantedDiscount : BuyAccounts.earnedDiscount;
    final Account additionAccount = isSales ? SalesAccounts.differentRevenues : BuyAccounts.differentExpenses;

    if (vat > 0) {
      bonds[vatAccount] = [BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: vat)];
    }

    if (gifts > 0) {
      bonds[giftsAccount] = [BondItemModel(bondItemType: isSales ? BondItemType.debtor : BondItemType.creditor, amount: gifts)];
      bonds[settlementAccount] = [BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: gifts)];
    }

    if (discount > 0) {
      bonds[discountAccount] = [BondItemModel(bondItemType: BondItemType.creditor, amount: discount)];
    }

    if (addition > 0) {
      bonds[additionAccount] = [BondItemModel(bondItemType: isSales ? BondItemType.creditor : BondItemType.debtor, amount: addition)];
    }
  }

// Build DataGrid rows based on bond model
  List<DataGridRow> buildBondDataGridRows() {
    return bondModel.bonds.entries.expand<DataGridRow>((entry) {
      Account account = entry.key;
      List<BondItemModel> bondItems = entry.value;

      return bondItems.map<DataGridRow>((bondItem) {
        return DataGridRow(cells: [
          DataGridCell<String>(columnName: AppConstants.rowBondAccount, value: account.label),
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
