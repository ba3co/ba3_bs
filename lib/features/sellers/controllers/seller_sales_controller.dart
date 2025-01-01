import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/implementations/bulk_savable_datasource_repo.dart';
import 'package:ba3_bs/features/pluto/controllers/pluto_controller.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/filterable_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../bill/data/models/bill_model.dart';

class SellerSalesController extends GetxController with AppNavigator {
  final FilterableDataSourceRepository<BillModel> _billsFirebaseRepo;
  final BulkSavableDatasourceRepository<SellerModel> _sellersFirebaseRepo;

  SellerSalesController(this._billsFirebaseRepo, this._sellersFirebaseRepo);

  // List of bills for the seller
  final List<BillModel> sellerBills = [];
  final List<BillModel> filteredBills = [];

  bool isLoading = false;

  SellerModel? selectedSeller;

  PickerDateRange? dateRange;

  bool get inFilterMode => dateRange != null;

  List<BillModel> get sellerSales => inFilterMode ? filteredBills : sellerBills;

  double get totalSales => calculateTotalSales(sellerSales);

  Future<void> addSeller(SellerModel seller) async {
    final result = await _sellersFirebaseRepo.save(seller);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSellers) {},
    );
  }

  Future<void> addSellers(List<SellerModel> sellers) async {
    final result = await _sellersFirebaseRepo.saveAll(sellers);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedSellers) {},
    );
  }

  set setSelectedSeller(SellerModel sellerModel) {
    selectedSeller = sellerModel;
  }

  Future<void> onSubmitDateRangePicker(PickerDateRange pickedDateRange) async {
    isLoading = true;
    update();

    dateRange = pickedDateRange;
    await fetchSellerBillsByDate(
      sellerModel: selectedSeller!,
      dateTimeRange: DateTimeRange(start: pickedDateRange.startDate!, end: pickedDateRange.endDate!),
    );

    isLoading = false;
    update();
  }

  void clearFilter() {
    dateRange = null;
    read<PlutoController>().updatePlutoKey();

    update();
  }

  // Sets the selected seller and fetches their bills
  Future<void> onSelectSeller(SellerModel sellerModel) async {
    setSelectedSeller = sellerModel;
    await fetchSellerBillsByDate(sellerModel: sellerModel);
    navigateToSellerSalesScreen();
  }

  Future<void> fetchSellerBillsByDate({required SellerModel sellerModel, DateTimeRange? dateTimeRange}) async {
    final currentDate = DateTime.now();
    final startOfDay = currentDate.subtract(Duration(days: 30));
    final endOfDay = currentDate;

    final result = await _billsFirebaseRepo.fetchWhere(
      field: ApiConstants.billSellerId,
      value: sellerModel.costGuid,
      dateFilter: DateFilter(
          dateFieldName: ApiConstants.billDate,
          range: dateTimeRange ?? DateTimeRange(start: startOfDay, end: endOfDay)),
    );
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (bills) => _handleGetSellerBillsStatusSuccess(bills),
    );
  }

  _handleGetSellerBillsStatusSuccess(List<BillModel> bills) {
    if (inFilterMode) {
      filteredBills.assignAll(bills);
    } else {
      sellerBills.assignAll(bills);
    }
  }

  // Method to calculate the total sales
  double calculateTotalSales(List<BillModel> bills) =>
      bills.fold(0.0, (sum, bill) => sum + (bill.billDetails.billTotal ?? 0));

  void navigateToAddSellerScreen() => to(AppRoutes.addSellerScreen);

  void navigateToAllSellersScreen() => to(AppRoutes.allSellersScreen);

  void navigateToSellerSalesScreen() => to(AppRoutes.sellerSalesScreen);
}
