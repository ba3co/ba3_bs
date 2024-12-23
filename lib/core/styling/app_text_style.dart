
import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {

  static TextStyle textStyle =
  const TextStyle(  fontFamily: 'Almarai',color: AppColors.textColor, fontSize: 16, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle1 =
  const TextStyle(  fontFamily: 'Almarai',fontSize: 26, color: AppColors.textColor, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis,);

  static TextStyle headLineStyle2 =
  const TextStyle(  fontFamily: 'Almarai',fontSize: 21, color: AppColors.textColor, fontWeight: FontWeight.bold,overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle3 =  const TextStyle(  fontFamily: 'Almarai',
      fontSize: 17, color: AppColors.textColor, fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis);

  static TextStyle headLineStyle4 =  const TextStyle(  fontFamily: 'Almarai',
      fontSize: 14, color: AppColors.textColor , fontWeight: FontWeight.w500,overflow: TextOverflow.ellipsis);
}
