import 'dart:developer';

import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/pluto/controllers/pluto_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/add_seller_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:ba3_bs/features/sellers/data/models/seller_model.dart';
import 'package:ba3_bs/features/sellers/ui/screens/add_seller_screen.dart';
import 'package:ba3_bs/features/sellers/ui/screens/all_sellers_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../bill/data/models/bill_model.dart';
import '../../patterns/data/models/bill_type_model.dart';
import '../ui/widgets/target_pointer_widget.dart';

class SellerSalesController extends GetxController with AppNavigator,FloatingLauncher {
  final CompoundDatasourceRepository<BillModel, BillTypeModel> _billsFirebaseRepo;

  SellerSalesController(this._billsFirebaseRepo);

  // List of bills for the seller
  final List<BillModel> sellerBills = [];
  final List<BillModel> filteredBills = [];

  bool isLoading = false;

  SellerModel? selectedSeller;

  PickerDateRange? dateRange;

  Rx<RequestState> profileScreenState = RequestState.initial.obs;

  final GlobalKey<TargetPointerWidgetState> accessoriesKey = GlobalKey<TargetPointerWidgetState>();
  final GlobalKey<TargetPointerWidgetState> mobilesKey = GlobalKey<TargetPointerWidgetState>();

  bool inFilterMode = false;

  List<BillModel> get sellerSales => inFilterMode ? filteredBills : sellerBills;

  double get totalSales => calculateTotalSales(sellerSales);

  double totalAccessoriesSales = 0.0;
  double totalMobilesSales = 0.0;

  set setSelectedSeller(SellerModel sellerModel) {
    selectedSeller = sellerModel;
  }

  set setInFilterMode(bool newValue) {
    inFilterMode = newValue;
  }

  set setDateRange(PickerDateRange newValue) {
    dateRange = newValue;
  }

  bool isValidDateRange() {
    if (dateRange == null) {
      return false;
    }

    final startDate = dateRange!.startDate;
    final endDate = dateRange!.endDate;

    if (endDate == null && startDate != null) {
      log('dateRange!.endDate == null');

      /// Last day of the month
      ///
      /// setting the day to 0 in the DateTime constructor rolls back to the last day of the previous month.
      final lastDayOfMonth = DateTime(startDate.year, startDate.month + 1, 0);
      setDateRange = PickerDateRange(startDate, lastDayOfMonth);
      update();
    } else if (startDate == null && endDate != null) {
      log('dateRange!.startDate == null');
      final startDay = DateTime(endDate.year, endDate.month, 1); // First day of the month
      setDateRange = PickerDateRange(startDay, endDate);
      update();
    }

    return true;
  }

  Future<void> onSubmitDateRangePicker() async {
    if (!isValidDateRange()) return;

    log('onSubmitDateRangePicker ${dateRange!.startDate}, ${dateRange!.endDate}');
    isLoading = true;
    update();

    setInFilterMode = true;

    await fetchSellerBillsByDate(
      sellerModel: selectedSeller!,
      dateTimeRange: DateTimeRange(start: dateRange!.startDate!, end: dateRange!.endDate!),
    );

    isLoading = false;
    update();
  }

  void onSelectionChanged(dateRangePickerSelectionChangedArgs) {
    setDateRange = dateRangePickerSelectionChangedArgs.value;
  }

  PickerDateRange get defaultDateRange {
    final currentDate = DateTime.now();
    final startDay = DateTime(currentDate.year, currentDate.month, 1);

    return PickerDateRange(startDay, currentDate);
  }

  void clearFilter() {
    setDateRange = defaultDateRange;

    setInFilterMode = false;
    filteredBills.assignAll([]);

    read<PlutoController>().updatePlutoKey();
    update();
  }

  // Sets the selected seller and fetches their bills
  Future<void> onSelectSeller({SellerModel? sellerModel, String? sellerId}) async {
    if (sellerModel == null && sellerId == null) return;
    profileScreenState.value = RequestState.loading;
    sellerModel ??= read<SellersController>().getSellerById(sellerId!);
    setDateRange = defaultDateRange;

    setSelectedSeller = sellerModel;

    await fetchSellerBillsByDate(
      sellerModel: sellerModel,
      dateTimeRange: DateTimeRange(start: defaultDateRange.startDate!, end: defaultDateRange.endDate!),
    );
  }

  Future<void> fetchSellerBillsByDate({required SellerModel sellerModel, required DateTimeRange dateTimeRange}) async {
    final result = await _billsFirebaseRepo.fetchWhere(
      itemIdentifier: BillType.sales.billTypeModel,
      field: ApiConstants.billSellerId,
      value: sellerModel.costGuid,
      dateFilter: DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: dateTimeRange,
      ),
    );

    result.fold(
      (failure) {
        if (inFilterMode) {
          AppUIUtils.onFailure(' لا توجد أي فواتير مسجلة لـ ${sellerModel.costName} في هذا التاريخ❌ ');
          totalAccessoriesSales = 0;
          totalMobilesSales = 0;
          clearFilter();
        }
        sellerBills.clear();
      },
      (bills) => _handleGetSellerBillsStatusSuccess(bills),
    );
  }

  _handleGetSellerBillsStatusSuccess(List<BillModel> bills) {
    if (inFilterMode) {
      filteredBills.assignAll(bills);
    } else {
      sellerBills.assignAll(bills);
    }
    calculateTotalAccessoriesMobiles();
  }

  // Method to calculate the total sales
  double calculateTotalSales(List<BillModel> bills) => bills.fold(0.0, (sum, bill) => sum + (bill.billDetails.billTotal ?? 0));

  void calculateTotalAccessoriesMobiles() {
    // Reset totals
    totalAccessoriesSales = 0;
    totalMobilesSales = 0;

    final bills = inFilterMode ? filteredBills : sellerBills;
    log("calculateTotalAccessoriesMobiles ${bills.length}");

    // Iterate through all bills
    for (final bill in bills) {
      // Iterate through all items in each bill
      for (final item in bill.items.itemList) {
        if (item.itemSubTotalPrice != null) {
          double itemTotal = item.itemTotalPrice.toDouble;

          if (item.itemSubTotalPrice! < 1000) {
            totalAccessoriesSales += itemTotal;
          } else {
            totalMobilesSales += itemTotal;
          }
        }
      }
    }
    profileScreenState.value = RequestState.success;
    update();
  }

  void navigateToAddSellerScreen({SellerModel? seller,required BuildContext context}) {
    read<AddSellerController>().init(seller);
    launchFloatingWindow(context: context, floatingScreen: AddSellerScreen(),defaultHeight: 100.h,defaultWidth: 200.w);

    // to(AppRoutes.addSellerScreen);
  }

  void navigateToAllSellersScreen(BuildContext context) async {
    launchFloatingWindow(context: context, floatingScreen: AllSellersScreen());

    // to(AppRoutes.allSellersScreen);
  }

  void navigateToSellerSalesScreen(SellerModel sellerModel) async {
    sellerBills.clear();
    await onSelectSeller(sellerModel: sellerModel);
    if (sellerBills.isNotEmpty) {
      to(AppRoutes.sellerSalesScreen);
    } else {
      AppUIUtils.onFailure(' لا توجد فواتير مسجلة لـ ${sellerModel.costName} في هذا التاريخ❌ ');
    }
  }

  void navigateToSellerTargetScreen() => to(AppRoutes.sellerTargetScreen);

  List<SellerSalesData> aggregateSalesBySeller({
    required List<BillModel> bills,
    required String Function(String sellerId) getSellerNameById,
  }) {
    final Map<String, double> salesMap = {};

    for (final bill in bills) {
      // الحصول على معرف البائع
      final sellerId = bill.billDetails.billSellerId ?? 'unknown';
      if(getSellerNameById(sellerId)=='') continue;
      // الحصول على إجمالي المبيعات لهذه الفاتورة
      final billTotal = bill.billDetails.billTotal ?? 0.0;
      salesMap[sellerId] = (salesMap[sellerId] ?? 0.0) + billTotal;
    }

    // تحويل البيانات إلى قائمة SellerSalesData باستخدام اسم البائع
    return salesMap.entries.map((entry) {
      final sellerName = getSellerNameById(entry.key);
      return SellerSalesData(sellerName: sellerName, totalSales: entry.value);
    }).toList();
  }

}