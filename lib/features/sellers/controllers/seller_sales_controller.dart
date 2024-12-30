import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/filterable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../bill/data/models/bill_model.dart';

class SellerSalesController extends GetxController with AppNavigator {
  final FilterableDataSourceRepository<BillModel> _billsFirebaseRepo;

  SellerSalesController(this._billsFirebaseRepo);

  // List of bills for the seller
  final List<BillModel> sellerBills = [];

  // Total sales value
  final RxDouble totalSales = 0.0.obs;

  bool isLoading = true;

  Future<void> fetchSellerBillsByDate(String sellerId, DateTime specificDate) async {
    final startOfDay = specificDate.subtract(Duration(days: 30));
    final endOfDay = specificDate;

    final result = await _billsFirebaseRepo.fetchWhere(
      field: 'billSellerId',
      value: sellerId,
      dateFilter: DateFilter(field: 'billDate', range: DateTimeRange(start: startOfDay, end: endOfDay)),
    );

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedBills) => _handleGetSellerBillsStatusSuccess(fetchedBills),
    );

    isLoading = false;
    update();
  }

  _handleGetSellerBillsStatusSuccess(List<BillModel> fetchedBills) {
    sellerBills.assignAll(fetchedBills);
    // Update total sales
    calculateTotalSales();
  }

  // Method to calculate the total sales
  void calculateTotalSales() {
    totalSales.value = sellerBills.fold(0.0, (sum, bill) => sum + (bill.billDetails.billTotal!));
  }

  void navigateToAddSellerScreen() => to(AppRoutes.addSellerScreen);

  void navigateToAllSellersScreen() => to(AppRoutes.allSellersScreen);

// // Method to filter bills by a specific criterion (e.g., date range)
// List<Map<String, dynamic>> filterBillsByDate(DateTime startDate, DateTime endDate) {
//   return sellerBills.where((bill) {
//     final billDate = bill['date'] as DateTime;
//     return billDate.isAfter(startDate) && billDate.isBefore(endDate);
//   }).toList();
// }
//
// // Method to handle manual addition of a bill
// void addBill(Map<String, dynamic> newBill) {
//   sellerBills.add(newBill);
//   calculateTotalSales();
// }
//
// // Simulated database fetch method (replace with actual implementation)
// Future<List<Map<String, dynamic>>> fetchSellerBillsFromDatabase(String sellerId) async {
//   // Example data structure: [{'id': '1', 'amount': 100.0, 'date': DateTime.now()}, ...]
//   await Future.delayed(Duration(seconds: 1)); // Simulate delay
//   return [
//     {'id': '1', 'amount': 200.0, 'date': DateTime.now().subtract(Duration(days: 1))},
//     {'id': '2', 'amount': 150.0, 'date': DateTime.now()},
//   ];
// }
}
