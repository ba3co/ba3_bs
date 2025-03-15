import 'package:ba3_bs/features/dashboard/ui/widgets/cheques_chart/cheques_chart_summary_section.dart';
import 'package:ba3_bs/features/dashboard/ui/widgets/cheques_chart/cheques_timeline_chart.dart';
import 'package:flutter/material.dart';
import '../../../controller/cheques_timeline_controller.dart';

class ChequesTimelineBoard extends StatelessWidget {
  final ChequesTimelineController chequesTimelineController;

  const ChequesTimelineBoard({
    super.key,
    required this.chequesTimelineController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ChequesBarChart(chequesTimelineController: chequesTimelineController),
        ChequesChartSummarySection(controller: chequesTimelineController),
      ],
    );
  }
}