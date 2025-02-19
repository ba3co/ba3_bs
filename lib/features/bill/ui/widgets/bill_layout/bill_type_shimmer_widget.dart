import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class BillTypeShimmerWidget extends StatelessWidget {
  const BillTypeShimmerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: max(.25.sw, 350),
      height: 130,
      child: Stack(
        children: [
          // Main container with white background
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white, // Keep it white so elements are visible
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
                topLeft: Radius.circular(12),
              ),
              border: Border.all(
                  color: Colors.grey[300]!, width: 2), // Simulated border
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: max(.25.sw, 350),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        _buildShimmerBox(
                            width: 65,
                            height: 15), // Placeholder for "كل الفواتير"
                        _buildShimmerBox(width: 30, height: 15),
                      ],
                    ), // Placeholder for numbers
                    Row(
                      spacing: 5,
                      children: [
                        _buildShimmerBox(
                            width: 70,
                            height: 15), // Placeholder for "الفواتير المعلقة"
                        _buildShimmerBox(width: 30, height: 15),
                      ],
                    ), // Placeholder for pending bills count
                  ],
                ),
              ),
            ),
          ),
          // Title bar with shimmer effect
          Positioned(
            top: 0,
            right: 0,
            child: _buildShimmerBox(width: 220, height: 30, borderRadius: 5),
          ),


          Positioned(
            bottom: 15,
            right: 0,
            left: 0,
            child: Center(
              child: Container(
                width: 146,
                height: 35,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white, // Keep it white so elements are visible
                  borderRadius: const BorderRadius.all((Radius.circular(5))),
                  border: Border.all(
                      color: Colors.grey[300]!, width: 2), // Simulated border
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildShimmerBox(
                          width: 28,
                          height: 14), // Placeholder for "كل الفواتير"
                      _buildShimmerIcon(), // Shimmer effect for the "add" icon
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Shimmer effect for "add" icon shape
  Widget _buildShimmerIcon() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[400]!,
      highlightColor: Colors.grey[100]!,
      child: Icon(
        Icons.add, // Actual "add" icon
        size: 18,
        color: Colors.grey[300]!, // Matches shimmer background
      ),
    );
  }

  // Shimmer box method for individual elements
  Widget _buildShimmerBox(
          {required double width,
          required double height,
          double borderRadius = 4}) =>
      Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.grey[
                300]!, // Lighter grey to differentiate from shimmer background
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
      );
}