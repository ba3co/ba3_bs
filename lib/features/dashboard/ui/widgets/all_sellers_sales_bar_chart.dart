import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/features/dashboard/controller/dashboard_layout_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/helper/enums/enums.dart';
import 'chart_summary_section.dart';
import 'seller_date_filter_header.dart';

class AllSellersSalesBarChart extends StatelessWidget {
  final DashboardLayoutController controller;

  const AllSellersSalesBarChart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          SellerDateFilterHeader(controller: controller),
          controller.sellerBillsRequest.value == RequestState.loading
              ? Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  direction: ShimmerDirection.btt,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    height: 600.h,
                    width: 1.1.sw,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: ClampingScrollPhysics(),
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    height: 650.h,
                    width: 1.1.sw,
                    child: BarChart(
                      BarChartData(
                        maxY: controller.maxY,
                        barGroups: controller.barGroups,
                        borderData: FlBorderData(show: false),
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.black,
                            tooltipBorder: BorderSide(color: AppColors.backGroundColor),
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${rod.toY.toStringAsFixed(2)} ${AppStrings.aed.tr}',
                                TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              reservedSize: 40.h,
                              showTitles: true,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                int index = value.toInt();
                                if (index < 0 || index >= controller.sellerChartData.length) {
                                  return Container();
                                }
                                return SideTitleWidget(
                                  meta: meta,
                                  space: 4,
                                  child: Column(
                                    children: [
                                      Text(
                                        controller.sellerChartData[index].sellerName,
                                        style: AppTextStyles.headLineStyle3,
                                      ),
                                      Text(
                                        (controller.sellerChartData[index].totalAccessorySales + controller.sellerChartData[index].totalMobileSales)
                                            .toString()
                                            .formatNumber(),
                                        style: AppTextStyles.headLineStyle3,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ChartSummarySection(controller: controller),
        ],
      );
    });
  }
}