import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:get/get.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/custom_text_field_without_icon.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// نتيجة إعدادات اللصاقة: القيم التي ستُطبع (قابلة للتعديل من المستخدم).
class LabelSettingsResult {
  final String name;
  final String barcode;
  final String priceText;
  final String? batteryPercent;

  const LabelSettingsResult({
    required this.name,
    required this.barcode,
    required this.priceText,
    this.batteryPercent,
  });
}

/// واجهة إعدادات اللصاقة قبل الطباعة: اسم المادة، الباركود، السعر، نسبة البطارية.
/// تُعبأ تلقائياً من المادة ويمكن للمستخدم تعديلها.
Future<LabelSettingsResult?> showLabelSettingsDialog(
  BuildContext context, {
  required MaterialModel material,
}) async {
  LabelSettingsResult? result;
  final nameController = TextEditingController(
    text: material.matName ?? '',
  );
  final barcodeController = TextEditingController(
    text: material.matBarCode ?? '',
  );
  final rawPrice = material.endUserPrice?.trim() ?? '';
  final priceController = TextEditingController(
    text: rawPrice.isNotEmpty
        ? (rawPrice.contains('.') ? rawPrice : '$rawPrice.00')
        : '0.00',
  );
  final batteryController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  String? nameValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'أدخل اسم المادة';
    return null;
  }

  String? barcodeValidator(String? v) {
    if (v == null || v.trim().isEmpty) return AppStrings.barcodeIsRequired.tr;
    return null;
  }

  String? priceValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'أدخل السعر';
    return null;
  }

  await OverlayService.showDialog(
    context: context,
    height: .55.sh,
    width: .5.sw,
    content: StatefulBuilder(
      builder: (ctx, setState) {
        return AlertDialog(
          backgroundColor: AppColors.backGroundColor,
          insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          titlePadding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          contentPadding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          title: Row(
            children: [
              const Icon(Icons.label_rounded),
              SizedBox(width: 8.w),
              const Text('إعدادات اللصاقة'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(AppStrings.materialName.tr, style: Theme.of(ctx).textTheme.labelMedium),
                  SizedBox(height: 4.h),
                  CustomTextFieldWithoutIcon(
                    textEditingController: nameController,
                    validator: nameValidator,
                    height: 44,
                  ),
                  SizedBox(height: 12.h),
                  Text(AppStrings.barcode.tr, style: Theme.of(ctx).textTheme.labelMedium),
                  SizedBox(height: 4.h),
                  CustomTextFieldWithoutIcon(
                    textEditingController: barcodeController,
                    validator: barcodeValidator,
                    height: 44,
                  ),
                  SizedBox(height: 12.h),
                  Text('السعر (AED)', style: Theme.of(ctx).textTheme.labelMedium),
                  SizedBox(height: 4.h),
                  CustomTextFieldWithoutIcon(
                    textEditingController: priceController,
                    validator: priceValidator,
                    keyboardType: TextInputType.number,
                    isNumeric: true,
                    height: 44,
                  ),
                  SizedBox(height: 12.h),
                  Text('نسبة البطارية %', style: Theme.of(ctx).textTheme.labelMedium),
                  SizedBox(height: 4.h),
                  CustomTextFieldWithoutIcon(
                    textEditingController: batteryController,
                    keyboardType: TextInputType.number,
                    isNumeric: true,
                    height: 44,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => OverlayService.back(),
              child: const Text('إلغاء'),
            ),
            AppButton(
              title: 'التالي',
              iconData: Icons.arrow_forward_rounded,
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) return;
                final price = priceController.text.trim();
                final priceText = price.contains('.') ? 'AED $price' : 'AED $price.00';
                String? batteryPercent;
                final bat = batteryController.text.trim();
                if (bat.isNotEmpty) {
                  batteryPercent = bat.endsWith('%') ? bat : '$bat%';
                }
                result = LabelSettingsResult(
                  name: nameController.text.trim(),
                  barcode: barcodeController.text.trim(),
                  priceText: priceText,
                  batteryPercent: batteryPercent,
                );
                OverlayService.back();
              },
            ),
          ],
        );
      },
    ),
  );

  return result;
}
