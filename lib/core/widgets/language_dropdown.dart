import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/features/main_layout/controllers/main_layout_controller.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LanguageDropdown extends StatelessWidget {
  const LanguageDropdown({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainLayoutController>(
      builder: (controller) {
        return Container(
          height: AppConstants.constHeightTextField,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(

            child: DropdownButton2<Locale>(
              value: controller.currentLocale,
              dropdownStyleData: DropdownStyleData(
                offset: Offset(0, -10),
                maxHeight: 200,
              ),
              hint: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black,
                size: 14,
              ),
              onChanged: (Locale? newLocale) {
                if (newLocale != null) {
                  Get.updateLocale(newLocale);
                }
              },
              items: AppConstants.locales.map((Locale locale) {
                return DropdownMenuItem<Locale>(
                  value: locale,
                  child: Row(
                    children: [
                      Image.asset(
                        controller.getFlagAsset(locale),
                        width: 0.020.sw,
                        height: 0.020.sh,
                        fit: BoxFit.cover,
                      ),
                      SizedBox(width: 8),
                      Text(
                        controller.getLanguageName(locale),
                        style: TextStyle(fontSize: 12.sp, color: Colors.black),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
