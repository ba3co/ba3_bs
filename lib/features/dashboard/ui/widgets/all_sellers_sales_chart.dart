import 'package:ba3_bs/features/sellers/controllers/seller_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../bill/data/models/bill_model.dart';
import '../../../sellers/data/models/seller_model.dart';

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
    final data = read<SellerSalesController>(). aggregateSalesBySeller(bills: bills, getSellerNameById: getSellerNameById);
    return Container(
      padding: const EdgeInsets.all(16),
      height: 300,
      child: SfCartesianChart(
        title: ChartTitle(text: 'مبيعات جميع البائعين'),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'البائع'),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'إجمالي المبيعات'),
        ),
        tooltipBehavior: TooltipBehavior(enable: true),
        series: <CartesianSeries<dynamic, dynamic>>[
          ColumnSeries<SellerSalesData, String>(
            dataSource: data,
            xValueMapper: (SellerSalesData sales, _) => sales.sellerName,
            yValueMapper: (SellerSalesData sales, _) => sales.totalSales,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
            enableTooltip: true,
          )
        ],
      ),
    );
  }
}