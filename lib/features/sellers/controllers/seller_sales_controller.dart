import 'package:get/get.dart';

class SellerSalesController extends GetxController {
  // List of bills for the seller
  final RxList<Map<String, dynamic>> sellerBills = <Map<String, dynamic>>[].obs;

  // Total sales value
  final RxDouble totalSales = 0.0.obs;

  // Method to fetch bills for a specific seller
  Future<void> fetchBills(String sellerId) async {
    try {
      // Simulate fetching data (replace with actual API/Firestore call)
      final fetchedBills = await fetchSellerBillsFromDatabase(sellerId);

      // Update the list of bills
      sellerBills.assignAll(fetchedBills);

      // Update total sales
      calculateTotalSales();
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch bills: $e");
    }
  }

  // Method to calculate the total sales
  void calculateTotalSales() {
    totalSales.value = sellerBills.fold(
      0.0,
      (sum, bill) => sum + (bill['amount'] as double),
    );
  }

  // Method to filter bills by a specific criterion (e.g., date range)
  List<Map<String, dynamic>> filterBillsByDate(DateTime startDate, DateTime endDate) {
    return sellerBills.where((bill) {
      final billDate = bill['date'] as DateTime;
      return billDate.isAfter(startDate) && billDate.isBefore(endDate);
    }).toList();
  }

  // Method to handle manual addition of a bill
  void addBill(Map<String, dynamic> newBill) {
    sellerBills.add(newBill);
    calculateTotalSales();
  }

  // Simulated database fetch method (replace with actual implementation)
  Future<List<Map<String, dynamic>>> fetchSellerBillsFromDatabase(String sellerId) async {
    // Example data structure: [{'id': '1', 'amount': 100.0, 'date': DateTime.now()}, ...]
    await Future.delayed(Duration(seconds: 1)); // Simulate delay
    return [
      {'id': '1', 'amount': 200.0, 'date': DateTime.now().subtract(Duration(days: 1))},
      {'id': '2', 'amount': 150.0, 'date': DateTime.now()},
    ];
  }
}
