import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:ba3_bs/features/dashboard/controller/dashboard_layout_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/helper/enums/enums.dart';
import 'chart_summary_section.dart';
import 'date_filter_header.dart';

class AllSellersSalesPieChart extends StatelessWidget {
  final DashboardLayoutController controller;

  const AllSellersSalesPieChart({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        children: [
          DateFilterHeader(controller: controller),
          controller.sellerBillsRequest.value == RequestState.loading
              ? Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            direction: ShimmerDirection.btt,
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 400.h,
              width: 1.1.sw,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          )
              : Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            height: 600.h,
            width: 1.1.sw,
            child: PieChart(
              PieChartData(
                sections: _getPieChartSections(),

                borderData: FlBorderData(show: false),
                centerSpaceRadius:180,
                sectionsSpace: 0,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions || pieTouchResponse == null) return;
                    final touchedSection = pieTouchResponse.touchedSection;
                    if (touchedSection == null) return; // ✅ تجنب الأخطاء عند لمس مناطق غير صالحة
                  },
                ),
              ),
            ),
          ),
          ChartSummarySection(controller: controller),
        ],
      );
    });
  }


  List<PieChartSectionData> _getPieChartSections() {
    return List.generate(controller.sellerChartData.length, (index) {
      final seller = controller.sellerChartData[index];
      final totalSales = seller.totalAccessorySales + seller.totalMobileSales;

      return PieChartSectionData(
        value: totalSales.toDouble(),
        title: seller.sellerName,
        radius: 170,
        titleStyle: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
        color: _generateUniqueColor(index), // استخدام لون فريد لكل بائع
      );
    });
  }


  Color _generateUniqueColor(int index) {
    return Color.fromARGB(
      210,
      (index * 50) % 256,  // يتحكم في قيمة الأحمر
      (index * 40) % 256,  // يتحكم في قيمة الأخضر
      (index * 30) % 256, // يتحكم في قيمة الأزرق
    );
  }

}