import 'package:ba3_bs/core/styling/app_text_style.dart';
import 'package:flutter/material.dart';

class TowFieldRow extends StatelessWidget {
  const TowFieldRow({
    super.key,
    required this.firstItem,
    required this.secondItem,
    this.visible,
    this.spacing = 20,
  });

  final String firstItem;
  final String secondItem;

  final bool? visible;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return (visible ?? true)
        ? Row(
      spacing: spacing,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(firstItem,style: AppTextStyles.headLineStyle4.copyWith(color: Colors.white),textAlign: TextAlign.center,)),
        Expanded(child: Text(secondItem,style: AppTextStyles.headLineStyle4.copyWith(color: Colors.white),textAlign: TextAlign.center,)),
      ],
    )
        : SizedBox();
  }
}