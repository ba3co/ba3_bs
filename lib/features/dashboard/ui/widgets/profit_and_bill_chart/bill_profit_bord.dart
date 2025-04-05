import 'package:ba3_bs/features/dashboard/ui/widgets/profit_and_bill_chart/profit_date_month_header.dart';
import 'package:flutter/material.dart';
import '../../../controller/bill_profit_dashboard_controller.dart';
import 'monthly_chart_summary_section.dart';
import 'bill_profit_chart.dart';

class BillProfitBord extends StatelessWidget {
  final BillProfitDashboardController billProfitDashboardController;

  const BillProfitBord(
      {super.key, required this.billProfitDashboardController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ProfitDateFilterHeader(controller: billProfitDashboardController),
        BillProfitChart(
            billProfitDashboardController: billProfitDashboardController),
        MonthlyChartSummarySection(controller: billProfitDashboardController),
      ],
    );
  }
}
