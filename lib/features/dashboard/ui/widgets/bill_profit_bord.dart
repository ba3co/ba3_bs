import 'package:ba3_bs/features/dashboard/ui/widgets/profit_date_month_header.dart';
import 'package:flutter/material.dart';
import '../../controller/dashboard_layout_controller.dart';
import 'bill_profit_chart.dart';
import 'monthly_chart_summary_section.dart';

class BillProfitBord extends StatelessWidget {
  final DashboardLayoutController dashboardLayoutController;

  const BillProfitBord({super.key, required this.dashboardLayoutController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfitDateFilterHeader(controller: dashboardLayoutController),
        BillProfitChart(dashboardLayoutController: dashboardLayoutController),

        MonthlyChartSummarySection(controller: dashboardLayoutController),
      ],
    );
  }
}