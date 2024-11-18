import 'package:pluto_grid/pluto_grid.dart';

import '../../../features/bill/data/models/invoice_record_model.dart';

abstract class IPlutoController {
  /// Main table's state manager.
  PlutoGridStateManager get mainTableStateManager;

  /// State manager for additions and discounts.
  PlutoGridStateManager get additionsDiscountsStateManager;

  /// Updates the VAT total notifier.
  void updateVatTotalNotifier(double total);

  /// Triggers an update call for the controller.
  void update();

  /// Calculates the amount from a given ratio and total.
  String calculateAmountFromRatio(double ratio, double total);

  /// Computes the total including VAT.
  double get computeWithVatTotal;

  /// Computes the total excluding VAT.
  double get computeWithoutVatTotal;

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
}
