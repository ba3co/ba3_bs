import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../constants/app_constants.dart';

class DatePicker extends StatefulWidget {
  final Function(DateTime) onSubmit;
  final String? initDate;

  const DatePicker({super.key, required this.onSubmit, this.initDate});

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  @override
  Widget build(BuildContext context) {
    DateTime? date;
    return Container(
      height: AppConstants.constHeightTextField,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: const Border.symmetric(vertical: BorderSide(width: 1))),
      // width: 150,
      child: InkWell(
          onTap: () {
            Get.defaultDialog(
                title: "اختر يوم",
                content: SizedBox(
                  height: MediaQuery.sizeOf(context).height / 1.6,
                  width: MediaQuery.sizeOf(context).height / 1,
                  child: SfDateRangePicker(
                    initialDisplayDate: DateTime.tryParse(widget.initDate ?? ""),
                    enableMultiView: true,
                    backgroundColor: Colors.transparent,
                    headerStyle: const DateRangePickerHeaderStyle(backgroundColor: Colors.transparent),
                    navigationDirection: DateRangePickerNavigationDirection.vertical,
                    selectionMode: DateRangePickerSelectionMode.single,
                    monthViewSettings: const DateRangePickerMonthViewSettings(enableSwipeSelection: false),
                    showNavigationArrow: true,
                    navigationMode: DateRangePickerNavigationMode.scroll,
                    onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                      DateTime _ = dateRangePickerSelectionChangedArgs.value as DateTime;
                      date = _;
                    },
                  ),
                ),
                actions: [
                  ElevatedButton(
                      onPressed: () {
                        if (date != null) {
                          widget.onSubmit(date!);
                        }
                        Get.back();
                        setState(() {});
                      },
                      child: const Text("تم")),
                  ElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: const Text("إلغاء"))
                ]);
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Text(
                  widget.initDate != null
                      ? widget.initDate.toString().split(" ").first
                      : date == null
                          ? "اختر يوم"
                          : date.toString().split(" ").first,
                  style: const TextStyle(fontSize: 17),
                ),
                const Spacer(),
                const Icon(Icons.date_range)
              ],
            ),
          )),
    );
  }
}
