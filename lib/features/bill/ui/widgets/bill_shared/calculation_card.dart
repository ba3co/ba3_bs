import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalculationCard extends StatelessWidget {
  final double width;
  final Color color;
  final String value;
  final String label;
  final double? height;

  const CalculationCard({
    super.key,
    required this.width,
    required this.color,
    required this.value,
    required this.label,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      width: width,
      height: height ?? .08.sh,
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: FittedBox(
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 30, color: Colors.white),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
