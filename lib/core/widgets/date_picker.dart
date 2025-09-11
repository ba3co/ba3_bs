import 'dart:developer';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../features/floating_window/services/overlay_service.dart';
import '../constants/app_constants.dart';
import '../utils/app_ui_utils.dart';

class DatePicker extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final String? initDate;
  final Color? color;
  final bool canEditeDate;

  const DatePicker(
      {super.key, required this.onDateSelected, this.initDate, this.color,this.canEditeDate=true });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppConstants.constHeightTextField,
      child: GestureDetector(
        onTap: () async{
          if(!canEditeDate) {
            if(!(await AppUIUtils.askForPassword(context))){
              AppUIUtils.onFailure('لايمكنك تغيير التاريغ');
             return;
            }

          }
          if(!context.mounted)return;
            OverlayService.showDialog(
              context: context,
              height: .35.sh,
              width: .35.sw,
              showDivider: false,
              borderRadius: BorderRadius.circular(16),
              contentPadding: EdgeInsets.zero,
              title: AppStrings.choseDay.tr,
              color: AppColors.backGroundColor,
              content: ClipRRect(
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
                child: SfDateRangePicker(
                  initialDisplayDate: DateTime.tryParse(initDate ?? ""),
                  enableMultiView: false,
                  cancelText: AppStrings.cancel.tr,
                  onCancel: () {
                    OverlayService.back();
                  },
                  backgroundColor: AppColors.whiteColor,
                  headerStyle: const DateRangePickerHeaderStyle(
                      backgroundColor: Colors.transparent),
                  navigationDirection:
                  DateRangePickerNavigationDirection.vertical,
                  selectionMode: DateRangePickerSelectionMode.single,
                  monthViewSettings: const DateRangePickerMonthViewSettings(
                      enableSwipeSelection: true),
                  showNavigationArrow: false,
                  navigationMode: DateRangePickerNavigationMode.scroll,
                  onSelectionChanged: (dateRangePickerSelectionChangedArgs) {
                    DateTime selectedDate =
                    dateRangePickerSelectionChangedArgs.value as DateTime;
                    onDateSelected(selectedDate);
                    OverlayService.back();
                  },
                ),
              ),
              onCloseCallback: () {
                log('DatePicker Dialog Closed.');
              },
            );

        },
        child: CustomTextFieldWithoutIcon(
          enabled: false,
          filedColor: color,
          textEditingController: TextEditingController()..text = initDate ?? '',
        ),
      ),
    );
  }
}