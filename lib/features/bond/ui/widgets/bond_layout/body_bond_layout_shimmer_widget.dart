import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class BodyBondLayoutShimmerWidget extends StatelessWidget {
  const BodyBondLayoutShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: 67.w,
      height: 170.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 0.2,
          color: AppColors.grayColor,
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row (label + icon)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title placeholder
                Container(
                  width: 40.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                // Icon placeholder
                Container(
                  width: 0.035.sw,
                  height: 0.035.sh,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),


            const Spacer(),

            // Button placeholder (small rounded shimmer)
            Container(
              width: double.infinity,
              height: 35.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(5),
              ),
            )
          ],
        ),
      ),
    );
  }
}
