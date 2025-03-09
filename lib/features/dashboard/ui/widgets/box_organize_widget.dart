import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styling/app_text_style.dart';
import '../../../../core/widgets/app_spacer.dart';

class BoxOrganizeWidget extends StatelessWidget {
  const BoxOrganizeWidget(
      {super.key, required this.titleText, required this.subTitleText, required this.primaryColor, required this.secondaryColor});

  final String titleText;
  final String subTitleText;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 110.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [
            primaryColor,
            secondaryColor,
          ],
          begin: Alignment.topRight,
          end: Alignment.topLeft,
        ),
      ),
      child: Stack(
        children: [
          /*        Positioned(
            right: -15.w,
            child: Container(
              width: 35.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    secondaryColor,
                    primaryColor,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.topLeft,
                ),
                // color: Color(0xFF9C27B0),
              ),
            ),
          ),*/
          Positioned(
            top: -40.h,
            left: -30.w,
            child: Container(
              width: 70.w,
              height: 170.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(30),
              ),
            ),
          ),
          Positioned(
            bottom: 30.h,
            right: -12.w,
            child: Container(
              width: 25.w,
              height: 45.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(40),
              ),
            ),
          ),
          Positioned(
            bottom: -30.h,
            right: -15.w,
            child: Container(
              width: 35.w,
              height: 80.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha(40),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  titleText,
                  style: AppTextStyles.headLineStyle1.copyWith(color: Colors.white),
                ),
                VerticalSpace(),
                Text(
                  subTitleText,
                  style: AppTextStyles.headLineStyle2.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}