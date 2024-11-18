import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/string_extension.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../data/models/bill_model.dart';

class BillSearchController extends GetxController {
  late List<BillModel> bills;
  late BillModel currentBill;
  late int currentBillIndex;

  initSearchControllerBill({required List<BillModel> billsByCategory, required BillModel bill}) {
    bills = billsByCategory;
    currentBill = bill;
    currentBillIndex = bills.indexOf(currentBill);
  }

  // Method to get the current bill
  BillModel getCurrentBill() => bills[currentBillIndex];

  // Move to the last bill, or show an error if no bills are available
  void toLastBill() {
    if (bills.isEmpty) {
      _showFailureMessage();
      return;
    }

    // Update to the last bill in the list
    _updateCurrentBill(bills.length - 1);
  }

  // Set the current bill by bill number, or show an error if not found
  void getBillByNumber(String billNumber) {
    int? billNumberInt = billNumber.toInt;

    if (billNumberInt == null || billNumberInt < 1 || billNumberInt > bills.length) {
      _showFailureMessage();
      return;
    }

    final index = bills.indexWhere((bill) => bill.billDetails.billNumber == billNumberInt);
    if (index != -1) {
      _updateCurrentBill(index);
    } else {
      _showFailureMessage();
    }
  }

  // Move to the next bill, or show an error if at the end
  void getNextBill() {
    log('currentBillIndex: $currentBillIndex');
    if (currentBillIndex < bills.length - 1) {
      _updateCurrentBill(currentBillIndex + 1);
    } else {
      _showFailureMessage();
    }
  }

  // Move to the previous bill, or show an error if at the start
  void getPreviousBill() {
    log('currentBillIndex: $currentBillIndex');
    if (currentBillIndex > 0) {
      _updateCurrentBill(currentBillIndex - 1);
    } else {
      _showFailureMessage();
    }
  }

  // Helper to update current bill and notify listeners
  void _updateCurrentBill(int index) {
    currentBillIndex = index;
    currentBill = bills[index];
    _updateScreenWithCurrentBill();
  }

  // Update the screen with the current bill's details
  void _updateScreenWithCurrentBill() {
    final invoiceController = Get.find<BillDetailsController>();
    invoiceController.updateScreenWithBillData(currentBill);
  }

  // Utility method to show failure messages
  void _showFailureMessage() => AppUIUtils.onFailure('هذه الفاتورة غير متوفرة');
}
