import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../controller/dashboard_layout_controller.dart';

class BillProfitChart extends StatelessWidget {
  final DashboardLayoutController dashboardLayoutController;

  const BillProfitChart({super.key, required this.dashboardLayoutController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return dashboardLayoutController.profitsBillsRequest.value == RequestState.loading
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
          : Container(
              color: Colors.white,
              child: SizedBox(
                height: 600,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: LineChart(

                    LineChartData(

                      minX: dashboardLayoutController.minX,
                      maxX: dashboardLayoutController.maxX,
                      maxY: dashboardLayoutController.maxY,
                      gridData: FlGridData(show: true),
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {

                              return LineTooltipItem(

                                '${spot.y.toStringAsFixed(2)} ${AppStrings.aed.tr}',
                                TextStyle(
                                  color:spot.barIndex==0?spot.bar.color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),

                      titlesData: FlTitlesData(
                        topTitles: AxisTitles(),
                        rightTitles: AxisTitles(),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: Duration.millisecondsPerDay.toDouble(),
                            getTitlesWidget: (value, meta) {
                              return Text(
                                DateFormat('MMM dd').format(
                                  DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true),
                                ),
                                style: TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: true),
                      lineBarsData: [
                        if (dashboardLayoutController.isProfitVisible.value)

                          LineChartBarData(
                          spots: dashboardLayoutController.profitSpots,
                          isCurved: true,
                          color: AppColors.feesSaleColor,
                          barWidth: 3,

                          belowBarData: BarAreaData(show: true, color: AppColors.feesSaleColor.withOpacity(0.3)),
                          dotData: FlDotData(show: true),
                        ),
                        if (dashboardLayoutController.isTotalSalesVisible.value)

                          LineChartBarData(
                          spots: dashboardLayoutController.totalSellsSpots,
                          isCurved: true,
                          color: AppColors.totalSaleColor,
                          barWidth: 3,
                          belowBarData: BarAreaData(show: true, color: AppColors.totalSaleColor.withOpacity(0.3)),
                          dotData: FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
    });
  }
}