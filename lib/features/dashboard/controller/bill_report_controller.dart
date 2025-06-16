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

  final allBillsController = Get.find<AllBillsController>();

  late List<PickerDateRange> datesRanges;

  final now = DateTime.now();

  Future<void> onSubmitDateRangePicker(int index) async {
    /*   if (!isValidDateRange()) return;

    getBillsByDate();*/
    setDateRange(datesRanges[index], index);
    log('onSubmitDateRangePicker ${datesRanges[index].startDate}, ${datesRanges[index].endDate}');
  }

  void onSelectionChanged(dateRangePickerSelectionChangedArgs, int index) {
    setDateRange(dateRangePickerSelectionChangedArgs.value, index);
    update();
  }

  setDateRange(PickerDateRange newValue, int index) {
    datesRanges[index] = newValue;
  }

  bool isValidDateRange(int index) {
    final startDate = datesRanges[index].startDate;
    final endDate = datesRanges[index].endDate;

    if (endDate == null && startDate != null) {
      log('dateRange!.endDate == null');

      /// Last day of the month
      ///
      /// setting the day to 0 in the DateTime constructor rolls back to the last day of the previous month.
      final lastDayOfMonth = DateTime(startDate.year, startDate.month + 1, 0);
      setDateRange(PickerDateRange(startDate, lastDayOfMonth), index);
      update();
    } else if (startDate == null && endDate != null) {
      log('dateRange!.startDate == null');
      final startDay = DateTime(endDate.year, endDate.month, 1); // First day of the month
      setDateRange(PickerDateRange(startDay, endDate), index);
      update();
    }

    return true;
  }

  getBillsByDate(BillTypeModel billTypeModel, int index, BuildContext context) async {
    sellerBillsRequest.value = RequestState.loading;
    billsAtRangTime.assignAll(await allBillsController.fetchBillsByDate(
      billTypeModel,
      DateFilter(
        dateFieldName: ApiConstants.billDate,
        range: DateTimeRange(start: datesRanges[index].startDate ?? now, end: datesRanges[index].endDate ?? now),
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