import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bill_details.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/bill_model.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillSearchController extends GetxController {
  late List<BillModel> bills;
  late BillModel currentBill;
  late int currentBillIndex;

  late BillDetailsController billDetailsController;
  late BillDetailsPlutoController billDetailsPlutoController;

  /// Initializes the bill search with the given bills and controllers.
  void initialize({
    required List<BillModel> allBills,
    required BillModel newBill,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
  }) {
    bills = _prepareBillList(allBills, newBill);
    currentBillIndex = _getBillIndexByNumber(newBill.billDetails.billNumber);
    currentBill = bills[currentBillIndex];
    this.billDetailsController = billDetailsController;
    this.billDetailsPlutoController = billDetailsPlutoController;

    _setCurrentBill(currentBillIndex);
  }

  /// Prepares a list of bills with placeholders up to the last bill number.
  List<BillModel> _prepareBillList(List<BillModel> allBills, BillModel currentBill) {
    final placeholders = List<BillModel>.filled(
      allBills.last.billDetails.billNumber! - 1,
      _createPlaceholderBill(currentBill),
    );
    return [...placeholders, currentBill];
  }

  /// Creates a placeholder bill for missing entries.
  BillModel _createPlaceholderBill(BillModel referenceBill) {
    return BillModel(
      billTypeModel: referenceBill.billTypeModel,
      status: Status.pending,
      items: const BillItems(itemList: []),
      billDetails: BillDetails(
        billPayType: InvPayType.cash.index,
        billDate: DateTime.now(),
      ),
    );
  }

  /// Validates the bill number range.
  bool _isValidBillNumber(int? billNumber) {
    return billNumber != null && billNumber >= 1 && billNumber <= bills.last.billDetails.billNumber!;
  }

  /// Displays an error message for invalid bill numbers.
  void _showInvalidBillNumberError(int? billNumber) {
    final firstBillNumber = bills.first.billDetails.billNumber ?? 1;
    final lastBillNumber = bills.last.billDetails.billNumber!;
    final message = billNumber == null
        ? 'من فضلك أدخل رقم صحيح'
        : billNumber < firstBillNumber
            ? 'رقم الفاتورة غير متوفر. رقم أول فاتورة هو $firstBillNumber'
            : 'رقم الفاتورة غير متوفر. رقم أخر فاتورة هو $lastBillNumber';
    _displayErrorMessage(message);
  }

  /// Retrieves the index of a bill by its number.
  int _getBillIndexByNumber(int? billNumber) {
    return bills.indexWhere((bill) => bill.billDetails.billNumber == billNumber);
  }

  /// Updates a bill if it exists.
  void updateBill(BillModel updatedBill) {
    final billIndex = _getBillIndexByNumber(updatedBill.billDetails.billNumber);
    if (billIndex != -1) {
      bills[billIndex] = updatedBill;
      if (currentBillIndex == billIndex) currentBill = updatedBill;
      update();
    }
  }

  /// Removes a bill and reloads the current bill.
  void removeBill(BillModel billToDelete) {
    final billIndex = _getBillIndexByNumber(billToDelete.billDetails.billNumber);
    if (billIndex != -1) {
      bills.removeAt(billIndex);
      reloadCurrentBill();
    }
  }

  /// Reloads the current bill or shows an error if unavailable.
  void reloadCurrentBill() {
    if (currentBillIndex < bills.length) {
      _setCurrentBill(currentBillIndex);
    } else {
      _displayErrorMessage('لا يوجد فاتورة أخرى');
    }
  }

  /// Navigates to a bill by its number.
  Future<void> goToBillByNumber(int? billNumber) async =>
      await _navigateToBill(billNumber!, SearchControllerNavigateSource.byNumber);

  /// Moves to the next bill if possible.
  Future<void> next() async =>
      await _navigateToBill(currentBill.billDetails.billNumber! + 1, SearchControllerNavigateSource.byNext);

  /// Moves to the previous bill if possible.
  Future<void> previous() async =>
      await _navigateToBill(currentBill.billDetails.billNumber! - 1, SearchControllerNavigateSource.byPrevious);

  /// Moves to the next bill if possible.
  Future<void> jumpTenForward() async =>
      await _navigateToBill(currentBill.billDetails.billNumber! + 10, SearchControllerNavigateSource.byNext);

  /// Moves to the previous bill if possible.
  Future<void> jumpTenBackward() async =>
      await _navigateToBill(currentBill.billDetails.billNumber! - 10, SearchControllerNavigateSource.byPrevious);

  /// Moves to the next bill if possible.
  Future<void> first() async => await _navigateToBill(1, SearchControllerNavigateSource.byNext);

  /// Moves to the previous bill if possible.
  Future<void> last() async =>
      await _navigateToBill(bills.last.billDetails.billNumber!, SearchControllerNavigateSource.byPrevious);

  /// Helper method to fetch or navigate to a specific bill.
  Future<void> _navigateToBill(int billNumber, SearchControllerNavigateSource source) async {
    if (!_validateAndHandleBillNumber(billNumber)) return;

    if (_checkExistingBill(billNumber)) return;

    await _fetchAndNavigateToBill(billNumber, source);
  }

  bool _validateAndHandleBillNumber(int billNumber) {
    if (!_isValidBillNumber(billNumber)) {
      _showInvalidBillNumberError(billNumber);
      return false;
    }
    return true;
  }

  bool _checkExistingBill(int billNumber) {
    final existingBill = _findExistingBill(billNumber);
    if (existingBill != null) {
      log('Bill with number $billNumber already exists in the list.');
      _setCurrentBill(bills.indexOf(existingBill));
      return true;
    }
    return false;
  }

  /// Checks if the bill number exists in the list and returns its index, or null if not found.
  BillModel? _findExistingBill(int billNumber) =>
      bills.firstWhereOrNull((bill) => bill.billDetails.billNumber == billNumber);

  /// Fetches the bill by number and handles success or failure.
  Future<void> _fetchAndNavigateToBill(int billNumber, SearchControllerNavigateSource source) async {
    final result = await read<AllBillsController>().fetchBillByNumber(
      billTypeModel: currentBill.billTypeModel,
      billNumber: billNumber,
    );

    result.fold(
      (failure) => _handleFetchFailure(failure, billNumber, source),
      (fetchedBills) => _handleFetchSuccess(fetchedBills, billNumber),
    );
  }

  /// Handles a failed bill fetch and triggers navigation for adjacent bills if necessary.
  void _handleFetchFailure(Failure failure, int billNumber, SearchControllerNavigateSource source) {
    log('Fetching bill from source: $source');

    if (source == SearchControllerNavigateSource.byNext) {
      _navigateToBill(billNumber + 1, source);
    } else if (source == SearchControllerNavigateSource.byPrevious) {
      _navigateToBill(billNumber - 1, source);
    } else {
      _displayErrorMessage('لا يوجد فاتورة ${failure.message}');
    }
  }

  /// Handles a successful bill fetch and updates the list.
  void _handleFetchSuccess(List<BillModel> fetchedBills, int billNumber) {
    if (fetchedBills.isEmpty) {
      _displayErrorMessage('No bills returned from the fetch operation.');
      return;
    }

    bills[billNumber - 1] = fetchedBills.first;
    _setCurrentBill(billNumber - 1);
  }

  /// Updates the current bill and refreshes the screen`
  void _setCurrentBill(int index) {
    currentBillIndex = index;
    currentBill = bills[index];
    _updateBillDetailsOnScreen();
    update();
  }

  /// Refreshes the screen with the current bill's details
  void _updateBillDetailsOnScreen() {
    billDetailsController.updateBillDetailsOnScreen(
      currentBill,
      billDetailsPlutoController,
    );
  }

  /// Gets the current bill
  BillModel get getCurrentBill => bills[currentBillIndex];

  /// Checks if the current bill is the last in the list
  bool get isLast => currentBillIndex == bills.length - 1;

  /// Checks if the current bill is the last in the list
  bool get isFirst => currentBillIndex == 0;

  bool get isNew => currentBill.billId == null;
  bool get isCash => currentBill.billDetails.billPayType == InvPayType.cash.index;

  bool get isPending => currentBill.status == Status.pending;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);
}
