import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/bill/data/models/invoice_record_model.dart';
import '../../features/bond/data/models/pay_item_model.dart';

abstract class IPlutoController extends GetxController {
  /// Main table's state manager.
  PlutoGridStateManager get mainTableStateManager;

  /// State manager for additions and discounts.
  PlutoGridStateManager get additionsDiscountsStateManager;

  /// Calculates the amount from a given ratio and total.
  String calculateAmountFromRatio(double ratio, double total);

  /// Calculates the ratio from a given amount and total.
  String calculateRatioFromAmount(double amount, double total);

  /// Computes the total including VAT.
  double get computeWithVatTotal;

  /// Computes the total excluding VAT.
  double get computeBeforeVatTotal;

  /// Computes the total VAT amount.
  double get computeTotalVat;

  /// Computes the total number of gift items.
  int get computeGiftsTotal;

  /// Computes the total value of gifts.
  double get computeGifts;

  /// Computes the total additions.
  double get computeAdditions;

  /// Computes the total discounts.
  double get computeDiscounts;

  /// Calculates the final total after applying discounts and additions.
  double get calculateFinalTotal;

  /// Generates a list of invoice records from the table data.
  List<InvoiceRecordModel> get generateBillRecords;


  /// Generates a list of bond records from the table data.
  List<PayItem> get generateBondRecords;

  void moveToNextRow(PlutoGridStateManager stateManager, String cellField);

  void restoreCurrentCell(PlutoGridStateManager stateManager);
}
