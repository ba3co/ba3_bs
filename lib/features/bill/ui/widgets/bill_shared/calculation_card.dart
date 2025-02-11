import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CalculationCard extends StatelessWidget {
  final Color color;
  final String value;
  final String label;
  final double? width;
  final double? height;
  final bool? visible;

  const CalculationCard({
    super.key,
    required this.color,
    required this.value,
    required this.label,
     this.visible,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible??true,
      child: Container(
        width: width ?? 50.0.w,
        height: height ?? 80.h,
        padding: const EdgeInsets.all(2),
        // margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(5)),
        child: Stack(
          // crossAxisAlignment: CrossAxisAlignment.start,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Center(
              child: Text(
                value,
                style: TextStyle(fontSize: 14.sp, color: Colors.white),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Text(
                label,
                style: TextStyle(fontSize: 10.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
