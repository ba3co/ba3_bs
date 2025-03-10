import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_spacer.dart';

class ChartBoxWidget extends StatelessWidget {
  const ChartBoxWidget({
    super.key,
    required this.color,
    required this.text,
    required this.totals,
  });

  final String text;
  final String totals;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        HorizontalSpace(20),
        Container(
          height: 13,
          width: 13,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
        ),
        SizedBox(
          width: 18.w,
          child: Text(
            totals.formatNumber(),
            style: AppTextStyles.headLineStyle3,
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          text,
          style: AppTextStyles.headLineStyle3,
        ),
      ],
    );
  }
}