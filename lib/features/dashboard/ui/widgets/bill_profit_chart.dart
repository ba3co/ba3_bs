import 'package:ba3_bs/features/dashboard/ui/widgets/profit_date_month_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../bill/data/models/bill_model.dart';
import '../../../materials/controllers/material_controller.dart';
import '../../controller/dashboard_layout_controller.dart';
import 'chart_summary_section.dart';

class BillProfitChart extends StatelessWidget {
  final List<BillModel> bills;

  const BillProfitChart({super.key, required this.bills});

  @override
  Widget build(BuildContext context) {
    List<FlSpot> spots = _generateDailyProfitData();

    double minX = spots.isNotEmpty ? spots.first.x : 0;
    double maxX = spots.isNotEmpty ? spots.last.x : 1;
    return Column(
      children: [
        ProfitDateFilterHeader(controller: read<DashboardLayoutController>()),
        Container(
          color: Colors.white,
          child: SizedBox(
            height: 600,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: LineChart(
                LineChartData(
                  minX: minX,
                  maxX: maxX,
                  maxY: spots.map((e) => e.y).reduce((value, element) => value > element ? value : element)+10000,
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    topTitles: AxisTitles(),
                    rightTitles: AxisTitles(),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        // getTitlesWidget: (value, meta) {
                        //   return Text("\$${value.toStringAsFixed(1)}", style: TextStyle(fontSize: 12));
                        // },
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
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.2)),
                      dotData: FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        ChartSummarySection(controller: read<DashboardLayoutController>()),
      ],
    );
  }

  double getMaterialMinPriceById(String itemGuid) {
    return read<MaterialController>().getMaterialMinPriceById(itemGuid);
  }

  List<FlSpot> _generateDailyProfitData() {
    Map<String, double> dailyProfits = {};

    for (var bill in bills) {
      double totalProfit = 0.0;

      for (final item in bill.items.itemList) {
        double itemCalcPrice = getMaterialMinPriceById(item.itemGuid);

        if (item.itemSubTotalPrice != null) {
          totalProfit += item.itemSubTotalPrice! - itemCalcPrice;
        }
      }

      // استخراج التاريخ بشكل دقيق بدون وقت
      DateTime billDate = DateTime.utc(
        bill.billDetails.billDate!.year,
        bill.billDetails.billDate!.month,
        bill.billDetails.billDate!.day,
      );

      String dayKey = DateFormat('yyyy-MM-dd').format(billDate);

      // تجميع الأرباح اليومية
      if (dailyProfits.containsKey(dayKey)) {
        dailyProfits[dayKey] = dailyProfits[dayKey]! + totalProfit;
      } else {
        dailyProfits[dayKey] = totalProfit;
      }
    }

    // تحويل البيانات إلى قائمة نقاط FlSpot
    List<FlSpot> spots = dailyProfits.entries.map((entry) {
      DateTime date = DateFormat('yyyy-MM-dd').parseUtc(entry.key);
      double timestamp = date.millisecondsSinceEpoch.toDouble(); // ضبط النقاط على بداية اليوم بالضبط

      return FlSpot(timestamp, entry.value);
    }).toList();

    // ترتيب النقاط حسب التاريخ لضمان أن المخطط زمني صحيح
    spots.sort((a, b) => a.x.compareTo(b.x));

    return spots;
  }
}

/* bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              DateFormat('MMM dd').format(
                                DateTime.fromMillisecondsSinceEpoch(value.toInt()),
                              ),
                              style: TextStyle(fontSize: 10),
                            );
                          },
                        ),
                      ),*/