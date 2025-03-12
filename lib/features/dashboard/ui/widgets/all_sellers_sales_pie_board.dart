import 'package:ba3_bs/features/dashboard/controller/dashboard_layout_controller.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/all_sellers_sales_pie_chart.dart';
import 'package:flutter/material.dart';
import 'seller_chart_summary_section.dart';
import 'seller_date_filter_header.dart';

class AllSellersSalesPieBoard extends StatelessWidget {
  final DashboardLayoutController controller;

  const AllSellersSalesPieBoard({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SellerDateFilterHeader(controller: controller),
        AllSellersSalesPieChart(controller: controller),
        SellerChartSummarySection(controller: controller),
      ],
    );
  }




}