import 'package:ba3_bs/core/helper/extensions/task_status_extension.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/employee_date_month_header.dart';
import 'package:ba3_bs/features/users_management/data/models/user_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EmployeeCommitmentChart extends StatelessWidget {
  final List<UserModel> employees;

  const EmployeeCommitmentChart({super.key, required this.employees});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmployeeDateMonthHeader(),
        Container(
          color: Colors.white,
          child: AspectRatio(
            aspectRatio: 1.5,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  barGroups: _generateBarGroups(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              employees[value.toInt()].userName!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(show: true, checkToShowHorizontalLine: (value) => value % 10 == 0),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<BarChartGroupData> _generateBarGroups() {
    return employees.asMap().entries.map((entry) {
      final int index = entry.key;
      final UserModel employee = entry.value;
      final double commitmentScore = _calculateCommitment(employee);

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: commitmentScore,
            color: Colors.green,
            width: 20,
            borderRadius: BorderRadius.circular(6),
          ),
        ],
      );
    }).toList();
  }

  double _calculateCommitment(UserModel employee) {
    return ((employee.userTaskList?.where((element) => element.status.isDone).length ?? 0) -
            (employee.userTaskList?.where((element) => element.status.isFailed).length ?? 0)+1) /
        ((employee.userTimeModel?.values.fold(
                  0,
                  (previousValue, element) => previousValue + (element.totalLogInDelay ?? 0),
                ) ??
                0) +
            (employee.userTimeModel?.values.fold(
              0,
                  (previousValue, element) => previousValue!  + (element.totalOutEarlier ?? 0),
            ) ??
                0) +
            2) *
        100;
  }
}