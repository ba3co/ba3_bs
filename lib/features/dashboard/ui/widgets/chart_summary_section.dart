import 'package:ba3_bs/features/dashboard/controller/dashboard_layout_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/styling/app_colors.dart';
import '../screens/dash_board_layout.dart';

class ChartSummarySection extends StatelessWidget {
  final DashboardLayoutController controller;

  const ChartSummarySection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ChartColumn(
            items: [
              ChartItem(
                color: AppColors.totalSaleColor,
                text: AppStrings.totalSales.tr,
                total: controller.totalSales.toStringAsFixed(2),
              ),
              ChartItem(
                color: AppColors.mobileSaleColor,
                text: AppStrings.totalMobileTarget.tr,
                total: controller.totalSalesMobile.toStringAsFixed(2),
              ),
            ],
          ),
          ChartColumn(
            items: [
              ChartItem(
                color: AppColors.accessorySaleColor,
                text: AppStrings.totalAccessoriesTarget.tr,
                total: controller.totalSalesAccessory.toStringAsFixed(2),
              ),
              ChartItem(
                color: AppColors.totalSaleColor,
                text: AppStrings.totalFees.tr,
                total: controller.totalFees.toStringAsFixed(2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartColumn extends StatelessWidget {
  final List<ChartItem> items;

  const ChartColumn({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => ChartBoxWidget(
        color: item.color,
        text: item.text,
        totals: item.total,
      )).toList(),
    );
  }
}

class ChartItem {
  final Color color;
  final String text;
  final String total;

  ChartItem({required this.color, required this.text, required this.total});
}