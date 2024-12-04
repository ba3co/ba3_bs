import 'dart:developer';

import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bill_model.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillSearchController extends GetxController {
  late List<BillModel> bills;
  late BillModel currentBill;
  late int currentBillIndex;
  late BillDetailsController billDetailsController;
  late BillDetailsPlutoController billDetailsPlutoController;

  /// Initializes the bill search with the given bills and current bill
  void initializeBillSearch({
    required List<BillModel> billsByCategory,
    required BillModel bill,
    required BillDetailsController billDetailsController,
    required BillDetailsPlutoController billDetailsPlutoController,
  }) {
    bills = billsByCategory;
    currentBillIndex = bills.indexOf(bill);
    currentBill = bills[currentBillIndex];

    this.billDetailsController = billDetailsController;
    this.billDetailsPlutoController = billDetailsPlutoController;

    log('bills ${bills.length}');
    log('currentBillIndex $currentBillIndex');
    log('currentBillNumber ${currentBill.billDetails.billNumber}');
  }

  /// Gets the current bill
  BillModel get getCurrentBill => bills[currentBillIndex];

  /// Finds the index of the bill with the given number
  int _getBillIndexByNumber(int? billNumber) => bills.indexWhere((bill) => bill.billDetails.billNumber == billNumber);

  /// Updates the bill in the search results if it exists
  void updateBillInSearchResults(BillModel updatedBill) {
    final billIndex = _getBillIndexByNumber(updatedBill.billDetails.billNumber);

    if (billIndex != -1) {
      bills[billIndex] = updatedBill;
    }
    update();
  }

  /// Validates whether the given bill number is within range
  bool _isBillNumberValid(int? billNumber) =>
      billNumber != null &&
      billNumber >= bills.first.billDetails.billNumber! &&
      billNumber <= bills.last.billDetails.billNumber!;

  /// Handles invalid bill number cases by showing appropriate error messages
  void _handleInvalidBillNumber(int? billNumber) {
    final firstBillNumber = bills.first.billDetails.billNumber!;
    final lastBillNumber = bills.last.billDetails.billNumber!;

    final message = billNumber == null
        ? 'من فضلك أدخل رقم صحيح'
        : billNumber < firstBillNumber
            ? 'رقم الفاتورة غير متوفر. رقم أول فاتورة هو $firstBillNumber'
            : 'رقم الفاتورة غير متوفر. رقم أخر فاتورة هو $lastBillNumber';

    _showErrorMessage(message);
  }

  /// Navigates to the bill by its number
  void navigateToBillByNumber(int? billNumber) {
    if (!_isBillNumberValid(billNumber)) {
      _handleInvalidBillNumber(billNumber);
      return;
    }

    final billIndex = _getBillIndexByNumber(billNumber);

    if (billIndex != -1) {
      _updateCurrentBill(billIndex);
    } else {
      _showErrorMessage('الفاتورة غير موجودة');
    }
  }

  /// Moves to the next bill if possible
  void navigateToNextBill() {
    log('Navigating to next bill, current index: $currentBillIndex');
    if (currentBillIndex < bills.length - 1) {
      _updateCurrentBill(currentBillIndex + 1);
    } else {
      _showErrorMessage('لا يوجد فاتورة أخرى');
    }
  }

  /// Moves to the previous bill if possible
  void navigateToPreviousBill() {
    log('Navigating to previous bill, current index: $currentBillIndex');
    if (currentBillIndex > 0) {
      _updateCurrentBill(currentBillIndex - 1);
    } else {
      _showErrorMessage('لا يوجد فاتورة سابقة');
    }
  }

  /// Moves to the last bill in the list
  void navigateToLastBill() {
    if (bills.isEmpty) {
      _showErrorMessage('لا توجد فواتير متوفرة');
      return;
    }
    _updateCurrentBill(bills.length - 1);
  }

  /// Updates the current bill and refreshes the screen
  void _updateCurrentBill(int index) {
    currentBillIndex = index;
    currentBill = bills[index];
    _refreshScreenWithCurrentBill();
    update();
  }

  /// Refreshes the screen with the current bill's details
  void _refreshScreenWithCurrentBill() {
    billDetailsController.refreshScreenWithCurrentBillModel(currentBill, billDetailsPlutoController);
  }

  /// Checks if the current bill is the last in the list
  bool get isLast => currentBillIndex == bills.length - 1;

  bool get isNew => currentBill.billId == null;

  /// Displays an error message
  void _showErrorMessage(String message) => AppUIUtils.onFailure(message);
}
