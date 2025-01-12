import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:ba3_bs/core/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/styling/app_text_style.dart';

class LoginHeaderText extends StatelessWidget {
  const LoginHeaderText({
    super.key,
    this.text,
  });

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            AppAssets.loginLogo,
            width: 0.25.sw,
            height: 0.25.sw,
            fit: BoxFit.cover,
          ),
        ),
        if (text != null)
          AnimatedTextKit(
            repeatForever: true,
            animatedTexts: [
              TyperAnimatedText(
                text!,
                textAlign: TextAlign.center,
                textStyle: AppTextStyles.headLineStyle1,
              )
            ],
          )
      ],
    );
  }
}
