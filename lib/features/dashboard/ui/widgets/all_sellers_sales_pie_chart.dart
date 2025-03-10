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
            height: 400.h,
            width: 1.1.sw,
            child: IgnorePointer(
              ignoring: true,
              child: PieChart(
                PieChartData(
                  sections: _getPieChartSections(),
                  borderData: FlBorderData(show: false),
                  centerSpaceRadius: 60, // المساحة في المنتصف
                  sectionsSpace: 3, // المسافة بين القطاعات
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      if (!event.isInterestedForInteractions || pieTouchResponse == null) return;
                      final touchedSection = pieTouchResponse.touchedSection;
                      if (touchedSection == null) return; // ✅ تجنب الأخطاء عند لمس مناطق غير صالحة
                      print("Clicked on: ${controller.sellerChartData[touchedSection.touchedSectionIndex].sellerName}");
                    },
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

  /// **تحويل البيانات إلى أقسام مخطط دائري**
  List<PieChartSectionData> _getPieChartSections() {
    return List.generate(controller.sellerChartData.length, (index) {
      final seller = controller.sellerChartData[index];
      final totalSales = seller.totalAccessorySales + seller.totalMobileSales;

      return PieChartSectionData(
        value: totalSales.toDouble(),
        title: seller.sellerName,
        radius: 80, // حجم القطاع
        titleStyle: AppTextStyles.headLineStyle3.copyWith(color: Colors.white),
        color: _getChartColor(index), // لون مخصص لكل قطاع
      );
    });
  }

  /// **اختيار لون لكل قطاع بناءً على الفهرس**
  Color _getChartColor(int index) {
    final colors = [
      AppColors.totalSaleColor,
      AppColors.mobileSaleColor,
      AppColors.accessorySaleColor,
      Colors.orange,
      Colors.purple,
      Colors.blueGrey,
    ];
    return colors[index % colors.length]; // تجنب الخروج عن حدود القائمة
  }
}