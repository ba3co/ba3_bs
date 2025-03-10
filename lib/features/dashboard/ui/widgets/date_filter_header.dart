import 'package:ba3_bs/features/dashboard/controller/dashboard_layout_controller.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_colors.dart';
import '../../../../core/styling/app_text_style.dart';
import '../../../sellers/ui/widgets/date_range_picker.dart';

class DateFilterHeader extends StatelessWidget {
  final DashboardLayoutController controller;

  const DateFilterHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            DateRangePicker(
              onSubmit: controller.onSubmitDateRangePicker,
              pickedDateRange: controller.dateRange,
              onSelectionChanged: controller.onSelectionChanged,
            ),
            Spacer(),
            Text(
              AppStrings.sellers,
              style: AppTextStyles.headLineStyle1,
            ),
            Spacer(),
            IconButton(
              tooltip: AppStrings.swap.tr,
              icon: Icon(
                controller.crossFadeState == CrossFadeState.showFirst?   FontAwesomeIcons.chartPie: FontAwesomeIcons.chartSimple,
                color: AppColors.lightBlueColor,
              ),
              onPressed: controller.swapCrossFadeState,
            ),
            IconButton(
              tooltip: AppStrings.refresh.tr,
              icon: Icon(
                FontAwesomeIcons.refresh,
                color: AppColors.lightBlueColor,
              ),
              onPressed: controller.getSellersBillsByDate,
            ),
          ],
        ),
      ),
    );
  }
}