import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart'; // Make sure to import your DataGrid package

import '../../../core/base_classes/sales_account.dart';
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
      required double discount,
      required double gifts}) {
    switch (billType) {
      case BillType.sales:
        handleSales(customerAccount, total, vat, discount, gifts);
        break;
      case BillType.buy:
        handleBuy(total, discount, gifts);
        break;
      default:
        throw Exception('Invalid payment type'); // Handle unexpected pay types
    }
    initBondRecordDataSource(); // Call to build rows after creating bonds
  }

  // Handle sales for cash payment type
  void handleSales(CustomerAccount customerAccount, double totalCash, double vat, double discount, double gifts) {
    Map<SalesAccount, List<BondItemModel>> bonds = {};

    bonds[SalesAccounts.sales] = [BondItemModel(bondItemType: BondItemType.creditor, amount: totalCash)];

    bonds[customerAccount] = _createCashBoxBonds(totalCash, discount, vat);
    _addOptionalBonds(bonds, discount, gifts, vat);

    bondModel = BondModel(bonds: bonds);
  }

  // Handle sales for due payment type
  void handleBuy(double totalDue, double discount, double gifts) {
    // Map<SalesDueAccounts, List<BondItemModel>> bonds = {};
    //
    // bonds[SalesDueAccounts.sales] = [BondItemModel(bondItemType: BondItemType.creditor, amount: totalDue)];
    //
    // bonds[SalesDueAccounts.customer] = _createCustomerBonds(totalDue, discount);
    // _addOptionalBonds(bonds, discount, gifts);
    //
    // bondModel = BondModel(bonds: bonds);
  }

  // Create bonds for the cash box based on cash sales
  List<BondItemModel> _createCashBoxBonds(double totalCash, double discount, double vat) {
    return [
      if (discount > 0) BondItemModel(bondItemType: BondItemType.creditor, amount: discount),
      if (vat > 0) BondItemModel(bondItemType: BondItemType.debtor, amount: vat),
      BondItemModel(bondItemType: BondItemType.debtor, amount: totalCash),
    ];
  }

  // Add optional bonds for discounts and gifts
  void _addOptionalBonds(Map<SalesAccount, List<BondItemModel>> bonds, double discount, double gifts, double vat) {
    if (vat > 0) {
      bonds[SalesAccounts.vat] = [BondItemModel(bondItemType: BondItemType.creditor, amount: vat)];
    }

    if (discount > 0) {
      bonds[SalesAccounts.grantedDiscount] = [
        BondItemModel(bondItemType: BondItemType.debtor, amount: discount),
      ];
    }

    if (gifts > 0) {
      bonds[SalesAccounts.salesGifts] = [
        BondItemModel(bondItemType: BondItemType.debtor, amount: gifts),
      ];
      bonds[SalesAccounts.settlements] = [
        BondItemModel(bondItemType: BondItemType.creditor, amount: gifts),
      ];
    }
  }

// Build data grid rows from the bondModel
  List<DataGridRow> buildRowInit() {
    return bondModel.bonds.entries.expand<DataGridRow>((entry) {
      SalesAccount account = entry.key;
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
