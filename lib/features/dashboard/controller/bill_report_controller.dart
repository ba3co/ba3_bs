import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/models/date_filter.dart';
import '../../../core/network/api_constants.dart';
import '../../bill/controllers/bill/all_bills_controller.dart';
import '../../bill/data/models/bill_model.dart';
import '../../patterns/data/models/bill_type_model.dart';

class BillReportController extends GetxController {
  Rx<RequestState> sellerBillsRequest = RequestState.initial.obs;
  List<BillModel> billsAtRangTime = [];

  PickerDateRange datesRange = PickerDateRange(
      DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      ),
      DateTime.now());

  final allBillsController = Get.find<AllBillsController>();


  final now = DateTime.now();

  Future<void> onSubmitDateRangePicker() async {
    /*   if (!isValidDateRange()) return;

    getBillsByDate();*/
    setDateRange(datesRange);
    log('onSubmitDateRangePicker ${datesRange.startDate}, ${datesRange.endDate}');
  }

  void onSelectionChanged(dateRangePickerSelectionChangedArgs) {
    setDateRange(dateRangePickerSelectionChangedArgs.value);
    update();
  }

  setDateRange(PickerDateRange newValue) {
    datesRange = newValue;
    update();
  }

  bool isValidDateRange() {
    final startDate = datesRange.startDate;
    final endDate = datesRange.endDate;

    if (endDate == null && startDate != null) {
      log('dateRange!.endDate == null');

      /// Last day of the month
      ///
      /// setting the day to 0 in the DateTime constructor rolls back to the last day of the previous month.
      final lastDayOfMonth = DateTime(startDate.year, startDate.month + 1, 0);
      setDateRange(PickerDateRange(startDate, lastDayOfMonth),);
      update();
    } else if (startDate == null && endDate != null) {
      log('dateRange!.startDate == null');
      final startDay = DateTime(endDate.year, endDate.month, 1); // First day of the month
      setDateRange(PickerDateRange(startDay, endDate),);
      update();
    }

    return true;
  }

  getBillsByDate(BillTypeModel billTypeModel,PickerDateRange datesRange, BuildContext context) async {
    sellerBillsRequest.value = RequestState.loading;
    billsAtRangTime.assignAll(await allBillsController.fetchBillsByDate(
      billTypeModel,
      DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: DateTimeRange(start: datesRange.startDate ?? now, end: datesRange.endDate ?? now),
      ),
    ));

    log('getSellersBillsByDate ${billsAtRangTime.length}');
    update();
    sellerBillsRequest.value = RequestState.success;
    if (billsAtRangTime.isEmpty) return;

    if (!context.mounted) return;
    allBillsController.lunchBillsScreen(billsAtRangTime, context);
  }
}