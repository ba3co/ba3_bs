import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart'; // Make sure to import your DataGrid package
import '../../../core/constants/app_constants.dart';
import '../../../core/helper/enums/enums.dart';
import '../data/models/bond_record_model.dart';
import '../ui/widgets/bond_record_data_source.dart';

class BondController extends GetxController {
  late BondModel bondModel;

  late EntryBondRecordDataSource recordDataSource;

  // Method to create a sales bond based on payment type
  void createBond(
      {required BillType billType,
      required CustomerAccount customerAccount,
      required double total,
      required double vat,
      required double gifts,
      required double discount,
      required double addition}) {
    switch (billType) {
      case BillType.sales:
        handleSales(customerAccount, total, vat, gifts, discount, addition);
        break;
      case BillType.buy:
        handleBuy(customerAccount, total, vat, gifts, discount, addition);
        break;
      default:
        throw Exception('Invalid payment type'); // Handle unexpected pay types
    }
    initBondRecordDataSource(); // Call to build rows after creating bonds
  }

  // Handle sales invoice
  void handleSales(
      CustomerAccount customerAccount, double total, double vat, double gifts, double discount, double addition) {
    Map<Account, List<BondItemModel>> bonds = {};

    bonds[SalesAccounts.sales] = [BondItemModel(bondItemType: BondItemType.creditor, amount: total)];

    bonds[customerAccount] = _createCashBoxSalesBonds(total, vat, discount, addition);
    _addOptionalSalesBonds(bonds, gifts, vat, discount, addition);

    bondModel = BondModel(bonds: bonds);
  }

  // Handle buy invoice
  void handleBuy(
      CustomerAccount customerAccount, double total, double vat, double gifts, double discount, double addition) {
    Map<Account, List<BondItemModel>> bonds = {};

    // Create a bond for purchases
    bonds[BuyAccounts.purchases] = [BondItemModel(bondItemType: BondItemType.debtor, amount: total)];

    // Create bonds for cash box if applicable
    bonds[customerAccount] = _createCashBoxBuysBonds(total, vat, discount, addition);

    // Add optional bonds for discounts and gifts
    _addOptionalBuysBonds(bonds, gifts, vat, discount, addition);

    bondModel = BondModel(bonds: bonds);
  }

  // Create bonds for the cash box based on cash sales
  List<BondItemModel> _createCashBoxSalesBonds(double total, double vat, double discount, double addition) {
    return [
      if (vat > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: vat),
      if (discount > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: discount),
      if (addition > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: addition),
      BondItemModel(bondItemType: BondItemType.debtor, amount: total),
    ];
  }

  // Create bonds for the cash box based on cash buy
  List<BondItemModel> _createCashBoxBuysBonds(double total, double vat, double discount, double addition) {
    return [
      if (vat > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: vat),
      if (discount > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: discount),
      if (addition > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: addition),
      BondItemModel(bondItemType: BondItemType.creditor, amount: total),
    ];
  }

  // Add optional bonds for discounts and gifts
  void _addOptionalSalesBonds(
      Map<Account, List<BondItemModel>> bonds, double gifts, double vat, double discount, double addition) {
    if (vat > 0) {
      bonds[SalesAccounts.vat] = [BondItemModel(bondItemType: BondItemType.creditor, amount: vat)];
    }

    if (gifts > 0) {
      bonds[SalesAccounts.salesGifts] = [
        BondItemModel(bondItemType: BondItemType.debtor, amount: gifts),
      ];
      bonds[SalesAccounts.settlements] = [
        BondItemModel(bondItemType: BondItemType.creditor, amount: gifts),
      ];
    }

    if (discount > 0) {
      bonds[SalesAccounts.grantedDiscount] = [
        BondItemModel(bondItemType: BondItemType.debtor, amount: discount),
      ];
    }
    if (addition > 0) {
      bonds[SalesAccounts.differentRevenues] = [
        BondItemModel(bondItemType: BondItemType.creditor, amount: addition),
      ];
    }
  }

  // Add optional bonds for discounts and gifts
  void _addOptionalBuysBonds(
      Map<Account, List<BondItemModel>> bonds, double gifts, double vat, double discount, double addition) {
    if (vat > 0) {
      bonds[BuyAccounts.vat] = [BondItemModel(bondItemType: BondItemType.creditor, amount: vat)];
    }

    if (gifts > 0) {
      bonds[BuyAccounts.purchaseGifts] = [
        BondItemModel(bondItemType: BondItemType.creditor, amount: gifts),
      ];
      bonds[BuyAccounts.settlements] = [
        BondItemModel(bondItemType: BondItemType.debtor, amount: gifts),
      ];
    }

    if (discount > 0) {
      bonds[BuyAccounts.earnedDiscount] = [
        BondItemModel(bondItemType: BondItemType.creditor, amount: discount),
      ];
    }
    if (addition > 0) {
      bonds[BuyAccounts.differentExpenses] = [
        BondItemModel(bondItemType: BondItemType.debtor, amount: addition),
      ];
    }
  }

// Build data grid rows from the bondModel
  List<DataGridRow> buildRowInit() {
    return bondModel.bonds.entries.expand<DataGridRow>((entry) {
      Account account = entry.key;
      List<BondItemModel> bondItems = entry.value;

      return bondItems.map<DataGridRow>((bondItem) {
        return DataGridRow(cells: [
          DataGridCell<String>(columnName: AppConstants.rowBondAccount, value: account.label),
          // Adjust according to your account structure
          DataGridCell<double>(
            columnName: AppConstants.rowBondDebitAmount,
            value: bondItem.bondItemType == BondItemType.debtor ? bondItem.amount : 0.0,
          ),
          DataGridCell<double>(
            columnName: AppConstants.rowBondCreditAmount,
            value: bondItem.bondItemType == BondItemType.creditor ? bondItem.amount : 0.0,
          ),
          DataGridCell<String>(columnName: AppConstants.rowBondDescription, value: "Bond for ${account.toString()}"),
          // Customize as needed
        ]);
      });
    }).toList(); // Return an empty list if there are no bonds
  }

  void initBondRecordDataSource() {
    recordDataSource = EntryBondRecordDataSource();
  }
}
