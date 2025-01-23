import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bill_details.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/bill_model.dart';
import '../pluto/bill_details_pluto_controller.dart';

class BillSearchController extends GetxController {
  late List<BillModel> bills;
  late BillModel newtBill;
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
    newtBill = bills[currentBillIndex];
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
      if (currentBillIndex == billIndex) newtBill = updatedBill;
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
      await _navigateToBill(billNumber!, NavigateToBillSource.byNumber);

  /// Moves to the next bill if possible.
  Future<void> next() async => await _navigateToBill(newtBill.billDetails.billNumber! + 1, NavigateToBillSource.byNext);

  /// Moves to the previous bill if possible.
  Future<void> previous() async =>
      await _navigateToBill(newtBill.billDetails.billNumber! - 1, NavigateToBillSource.byPrevious);

  /// Moves to the last bill.
  void last() {
    if (bills.isEmpty) {
      _displayErrorMessage('لا توجد فواتير متوفرة');
    } else {
      _setCurrentBill(bills.length - 1);
    }
  }

  /// Helper method to fetch or navigate to a specific bill.
  Future<void> _navigateToBill(int billNumber, NavigateToBillSource source) async {
    if (!_isValidBillNumber(billNumber)) {
      _showInvalidBillNumberError(billNumber);
      return;
    }

    final existingBill = bills.firstWhereOrNull((bill) => bill.billDetails.billNumber == billNumber);
    if (existingBill != null) {
      log('Bill with number $billNumber already exists in the list.');
      _setCurrentBill(bills.indexOf(existingBill));
      return;
    }

    final result = await read<AllBillsController>().fetchBillByNumber(
      billTypeModel: newtBill.billTypeModel,
      billNumber: billNumber,
    );

    result.fold(
      (failure) {
        if (source == NavigateToBillSource.byNext) {
          log('source $source');
          _navigateToBill(billNumber + 1, source);
        } else if (source == NavigateToBillSource.byPrevious) {
          log('source $source');
          _navigateToBill(billNumber - 1, source);
        } else {
          log('source $source');
          _displayErrorMessage('لا يوجد فاتورة ${failure.message}');
        }
      },
      (fetchedBills) {
        // log('fetchedBill billNumber : ${fetchedBills.first.billDetails.billNumber}');
        // log('bills length before insert: '
        //     '${bills.length}');
        bills[billNumber - 1] = fetchedBills.first;
        //   log('bills length after insert: ${bills.length}');

        // for (final bill in bills) {
        //   log('billNumber: ${bill.billDetails.billNumber}, billId: ${bill.billId}');
        // }
        bills[billNumber - 1] = fetchedBills.first;
        _setCurrentBill(billNumber - 1);
      },
    );
  }

  /// Updates the current bill and refreshes the screen`
  void _setCurrentBill(int index) {
    currentBillIndex = index;
    newtBill = bills[index];
    _updateBillDetailsOnScreen();
    update();
  }

  /// Refreshes the screen with the current bill's details
  void _updateBillDetailsOnScreen() {
    billDetailsController.updateBillDetailsOnScreen(
      newtBill,
      billDetailsPlutoController,
    );
  }

  /// Gets the current bill
  BillModel get getCurrentBill => bills[currentBillIndex];

  /// Checks if the current bill is the last in the list
  bool get isLast => currentBillIndex == bills.length - 1;

  bool get isNew => newtBill.billId == null;

  bool get isPending => newtBill.status == Status.pending;

  /// Displays an error message
  void _displayErrorMessage(String message) => AppUIUtils.onFailure(message);
}

enum NavigateToBillSource { byNext, byPrevious, byNumber }
