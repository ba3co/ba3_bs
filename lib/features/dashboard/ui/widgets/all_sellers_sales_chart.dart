import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../bill/data/models/bill_model.dart';

class AllSellersSalesChart extends StatelessWidget {
  final List<BillModel> bills;
  final String Function(String sellerId) getSellerNameById;

  const AllSellersSalesChart({
    super.key,
    required this.bills,
    required this.getSellerNameById,
  });

  @override
  Widget build(BuildContext context) {
    final data =read<SellerSalesController>(). aggregateSalesBySeller(bills: bills, getSellerNameById: getSellerNameById);

    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < data.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: data[i].totalSales,
              width: 20,
              color: Colors.blue,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        ),
      );
    }

    double maxY = data.isNotEmpty
        ? data.map((d) => d.totalSales).reduce((a, b) => a > b ? a : b)
        : 0;
    maxY *= 1.1;

    return Container(
      padding: const EdgeInsets.all(16),
      height: 600.h,
      width: 2.sw,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          barGroups: barGroups,
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= data.length) {
                    return Container();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 4,
                    child: Text(
                      data[index].sellerName,
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}