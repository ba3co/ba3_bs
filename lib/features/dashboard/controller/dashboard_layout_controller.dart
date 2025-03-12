import 'dart:developer';

import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/cheques/controllers/cheques/all_cheques_controller.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:ba3_bs/features/dashboard/data/model/dash_account_model.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/users_management/controllers/user_management_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/models/date_filter.dart';
import '../../../core/services/local_database/implementations/repos/local_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../../accounts/controllers/account_statement_controller.dart';
import '../../accounts/controllers/accounts_controller.dart';
import '../../accounts/data/models/account_model.dart';
import '../../sellers/controllers/seller_sales_controller.dart';
import '../../sellers/data/models/seller_model.dart';
import '../../users_management/data/models/user_model.dart';

class DashboardLayoutController extends GetxController {
  final LocalDatasourceRepository<DashAccountModel> _datasourceRepository;

  List<DashAccountModel> dashBoardAccounts = [];
  TextEditingController accountNameController = TextEditingController();

  Rx<RequestState> fetchDashBoardAccountsRequest = RequestState.initial.obs;

  DashboardLayoutController(this._datasourceRepository);

  final now = DateTime.now();

  Rx<RequestState> sellerBillsRequest = RequestState.initial.obs;
  Rx<RequestState> profitsBillsRequest = RequestState.initial.obs;

  @override
  onInit() {
    getAllDashBoardAccounts();
    getSellersBillsByDate();
    initProfitChartData();
    super.onInit();
  }

  PickerDateRange? dateRange = PickerDateRange(DateTime.now(), DateTime.now());

  List<UserModel> get allUsers => read<UserManagementController>().allUsers;

  int get allUsersLength => allUsers.length;

  int get onlineUsersLength => allUsers
      .where(
        (user) => user.userWorkStatus == UserWorkStatus.online,
      )
      .length;

  int get usersMustWorkingNowLength => allUsers
      .where((user) {
        return user.userWorkingHours!.values.any((interval) {
          return now.isAfter(interval.enterTime!.toWorkingTime()) && now.isBefore(interval.outTime!.toWorkingTime());
        });
      })
      .toList()
      .length;

  List<ChequesModel> get allCheques => read<AllChequesController>().chequesList;

  int get allChequesLength => allCheques.length;

  int get allChequesDuesLength => allCheques
      .where(
        (user) => user.isPayed != true,
      )
      .length;

  /// this for cheques in this month
  List<ChequesModel> get allChequesDuesThisMonth => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now.add(Duration(days: 30))),
      )
      .toList();

  int get allChequesDuesThisMonthLength => allChequesDuesThisMonth.length;

  /// this for cheques Last 10 days
  List<ChequesModel> get allChequesDuesLastTen => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now.add(Duration(days: 10))),
      )
      .toList();

  int get allChequesDuesLastTenLength => allChequesDuesLastTen.length;

  /// this for cheques today
  List<ChequesModel> get allChequesDuesToday => allCheques
      .where(
        (user) => user.isPayed != true && DateTime.parse(user.chequesDueDate!).isBefore(now),
      )
      .toList();

  int get allChequesDuesTodayLength => allChequesDuesToday.length;
  List<BillModel> allBillsThisMonth = [];

  getSellersBillsByDate() async {
    sellerBillsRequest.value = RequestState.loading;
    allBillsThisMonth = await read<AllBillsController>().fetchBillsByDate(
      BillType.sales.billTypeModel,
      DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: DateTimeRange(start: dateRange?.startDate ?? now, end: dateRange?.endDate ?? now),
      ),
    );
    getChartData();
    update();
    sellerBillsRequest.value = RequestState.success;
  }

  getAllDashBoardAccounts() async {
    final result = await _datasourceRepository.getAll();
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedDashBoardAccounts) {
        dashBoardAccounts.assignAll(fetchedDashBoardAccounts);
        update();
      },
    );
  }

  refreshDashBoardAccounts() async {
    fetchDashBoardAccountsRequest.value = RequestState.loading;
    for (final account in dashBoardAccounts) {
      final AccountModel? accountModel = read<AccountsController>().getAccountModelById(account.id);

      final balance = await read<AccountStatementController>().getAccountBalance(accountModel!);
      account.balance = balance.toString();
      await _datasourceRepository.update(account);
    }
    fetchDashBoardAccountsRequest.value = RequestState.success;
    update();
  }

  DashAccountModel dashboardAccount(int index) {
    return dashBoardAccounts[index];
  }

  addDashBoardAccount() async {
    final AccountModel? accountModel = read<AccountsController>().getAccountModelByName(accountNameController.text);
    if (accountModel == null) {
      AppUIUtils.onFailure("يرجى إدخال اسم الحساب");
      return;
    }

    final balance = await read<AccountStatementController>().getAccountBalance(accountModel);
    final DashAccountModel dashAccountModel = DashAccountModel(
      id: accountModel.id,
      name: accountModel.accName,
      balance: balance.toString(),
    );
    final result = await _datasourceRepository.save(dashAccountModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedDashBoardAccounts) => AppUIUtils.onSuccess('تم حفظ الحساب بنجاح'),
    );
    getAllDashBoardAccounts();
    accountNameController.clear();
    update();
  }

  void onAccountNameSubmitted(String text, BuildContext context) async {
    final convertArabicNumbers = AppUIUtils.convertArabicNumbers(text);

    AccountModel? accountModel = await read<AccountsController>().openAccountSelectionDialog(
      query: convertArabicNumbers,
      context: context,
    );
    if (accountModel != null) {
      accountNameController.text = accountModel.accName!;
    }
  }

  deleteDashboardAccount(int index, BuildContext context) async {
    if (await AppUIUtils.confirm(
      context,
      title: 'هل تريد حذف الحساب؟',
    )) {
      final DashAccountModel dashAccountModel = dashBoardAccounts[index];
      final result = await _datasourceRepository.delete(dashAccountModel, dashAccountModel.id!);

      result.fold(
        (failure) => AppUIUtils.onFailure(failure.message),
        (fetchedDashBoardAccounts) => AppUIUtils.onSuccess('تم حذف الحساب بنجاح'),
      );
      getAllDashBoardAccounts();
      update();
    }
  }

  Future<void> onSubmitDateRangePicker() async {
    if (!isValidDateRange()) return;

    log('onSubmitDateRangePicker ${dateRange!.startDate}, ${dateRange!.endDate}');
    getSellersBillsByDate();
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

  set setDateRange(PickerDateRange newValue) {
    dateRange = newValue;
  }

  void onSelectionChanged(dateRangePickerSelectionChangedArgs) {
    setDateRange = dateRangePickerSelectionChangedArgs.value;
  }

  List<SellerSalesData> sellerChartData = [];
  List<BillModel> profitChartData = [];
  List<BarChartGroupData> sellerBarGroups = [];
  double sellerMaxY = 0;

  double totalSellerSales = 0;
  double totalSellerSalesAccessory = 0;
  double totalSellerSalesMobile = 0;
  double totalSellerFees = 0;
  double totalMonthSales = 0;
  double totalMonthFees = 0;

  CrossFadeState crossSellerFadeState = CrossFadeState.showFirst;

  double minX = 0;
  double maxX = 0;
  double maxY = 0;
  List<FlSpot> profitSpots = [];
  List<FlSpot> totalSellsSpots = [];
  Rx<DateTime> profitMonth = DateTime.now().obs;

  Rx<bool> isTotalSalesVisible = true.obs;

  Rx<bool> isProfitVisible = true.obs;

  set setProfitMonth(DateTime setMonth) {
    profitMonth.value = setMonth;
  }

  changeProfitVisibility() {
    isProfitVisible.value = !isProfitVisible.value;
    generateDailyProfitData();
  }
  changeTotalVisibility() {
    isTotalSalesVisible.value = !isTotalSalesVisible.value;
    generateDailyProfitData();
  }

  getProfitChartData() async {
    profitsBillsRequest.value = RequestState.loading;
    profitChartData = await read<AllBillsController>().fetchBillsByDate(
      BillType.sales.billTypeModel,
      DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: DateTimeRange(start: profitMonth.value.copyWith(day: 0), end: profitMonth.value.copyWith(day: 31)),
      ),
    );
    getChartData();
    update();
    totalMonthSales = profitChartData.fold(
      0,
      (previousValue, element) => previousValue + element.billDetails.billTotal!,
    );
    profitsBillsRequest.value = RequestState.success;
  }

  generateDailyProfitData() {
    Map<String, double> dailyProfits = {};
    Map<String, double> dailyTotal = {};
    totalMonthFees = 0;
    for (var bill in profitChartData) {
      double totalProfit = 0.0;

      for (final item in bill.items.itemList) {
        double itemCalcPrice = read<MaterialController>().getMaterialMinPriceById(item.itemGuid);

        if (item.itemSubTotalPrice != null) {
          totalProfit += item.itemSubTotalPrice! - itemCalcPrice;
          totalMonthFees += totalProfit;
        }
      }

      DateTime billDate = DateTime.utc(
        bill.billDetails.billDate!.year,
        bill.billDetails.billDate!.month,
        bill.billDetails.billDate!.day,
      );

      String dayKey = DateFormat('yyyy-MM-dd').format(billDate);

      if (dailyProfits.containsKey(dayKey)) {
        dailyProfits[dayKey] = dailyProfits[dayKey]! + totalProfit;
      } else {
        dailyProfits[dayKey] = totalProfit;
      }

      if (dailyTotal.containsKey(dayKey)) {
        dailyTotal[dayKey] = dailyTotal[dayKey]! + bill.billDetails.billTotal!;
      } else {
        dailyTotal[dayKey] = bill.billDetails.billTotal!;
      }
    }

    profitSpots = dailyProfits.entries.map((entry) {
      DateTime date = DateFormat('yyyy-MM-dd').parseUtc(entry.key);
      double timestamp = date.millisecondsSinceEpoch.toDouble(); // ضبط النقاط على بداية اليوم بالضبط

      return FlSpot(timestamp, entry.value);
    }).toList();
    totalSellsSpots = dailyTotal.entries.map((entry) {
      DateTime date = DateFormat('yyyy-MM-dd').parseUtc(entry.key);
      double timestamp = date.millisecondsSinceEpoch.toDouble(); // ضبط النقاط على بداية اليوم بالضبط

      return FlSpot(timestamp, entry.value);
    }).toList();

    profitSpots.sort((a, b) => a.x.compareTo(b.x));
    minX = profitSpots.isNotEmpty ? profitSpots.first.x : 0;
    maxX = profitSpots.isNotEmpty ? profitSpots.last.x : 1;
    maxY = totalSellsSpots.map((e) => e.y).reduce((value, element) => value > element ? value : element) + 10000;

    update();
  }

  swapSellerCrossFadeState() {
    if (crossSellerFadeState == CrossFadeState.showFirst) {
      crossSellerFadeState = CrossFadeState.showSecond;
    } else if (crossSellerFadeState == CrossFadeState.showSecond) {
      crossSellerFadeState = CrossFadeState.showFirst;
    }
    update();
  }

  getChartData() {
    sellerChartData = read<SellerSalesController>().aggregateSalesBySeller(bills: allBillsThisMonth);
    totalSellerSales = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalAccessorySales + element.totalMobileSales,
    );
    totalSellerSalesAccessory = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalAccessorySales,
    );
    totalSellerSalesMobile = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalMobileSales,
    );
    totalSellerFees = sellerChartData.fold(
      0,
      (previousValue, element) => previousValue + element.totalFess,
    );
    _getBarGroups();
  }
 bool sellerTotalFees=true;

  changeSellerTotalFees() {
    sellerTotalFees=!sellerTotalFees;
    _getBarGroups();
    update();
  }
  _getBarGroups() {
    sellerBarGroups.clear();
    for (int i = 0; i < sellerChartData.length; i++) {
      sellerBarGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            if(isSellerMobileTargetVisible)
            BarChartRodData(
              toY: sellerChartData[i].totalMobileSales,
              width: 20,
              color: AppColors.mobileSaleColor,
              borderRadius: BorderRadius.circular(3),
            ),
            if(isSellerAccessoryTargetVisible)
            BarChartRodData(
              toY: sellerChartData[i].totalAccessorySales,
              width: 20,
              color: AppColors.accessorySaleColor,
              borderRadius: BorderRadius.circular(3),
            ),
            if(sellerTotalFees)
            BarChartRodData(
              toY: sellerChartData[i].totalFess,
              width: 20,
              color: AppColors.feesSaleColor,
              borderRadius: BorderRadius.circular(3),
            ),
          ],
        ),
      );
    }

    sellerMaxY = sellerChartData.isNotEmpty ? sellerChartData.map((d) => d.totalMobileSales).reduce((a, b) => a > b ? a : b) : 0;
    sellerMaxY *= 1.5;
  }

  initProfitChartData() async {
    await getProfitChartData();
    generateDailyProfitData();
  }

  void onProfitMothChange(DateTime date) async {
    setProfitMonth = date;
    await initProfitChartData();
    _getBarGroups();
    update();
  }
bool isSellerMobileTargetVisible=true;
  void changeSellerTotalMobileTarget() {
    isSellerMobileTargetVisible=!isSellerMobileTargetVisible;
    _getBarGroups();
    update();
  }
  bool isSellerAccessoryTargetVisible=true;
  void changeSellerAccessoryTarget() {
    isSellerAccessoryTargetVisible=!isSellerAccessoryTargetVisible;
    _getBarGroups();
    update();
  }
}