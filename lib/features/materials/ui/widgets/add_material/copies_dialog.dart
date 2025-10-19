import 'dart:async';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/widgets/custom_text_field_without_icon.dart';

Future<int?> pickCopiesDialog(
  BuildContext context, {
  int initial = 1,
  int min = 1,
  int max = 500,
  int step = 1,
}) async {
  int value = initial.clamp(min, max);
  int? result;
  final txt = TextEditingController(text: value.toString());
  final formKey = GlobalKey<FormState>();

  void syncFromText() {
    final n = int.tryParse(txt.text);
    if (n != null) {
      value = n.clamp(min, max);
    }
  }

  await OverlayService.showDialog(
    context: context,
    height: .4.sh,
    width: .44.sw,
    content: StatefulBuilder(
      builder: (ctx, setState) {
        void applyAndRefresh(int newVal) {
          value = newVal.clamp(min, max);
          txt.text = value.toString();
          setState(() {});
        }

        return AlertDialog(
          backgroundColor: AppColors.backGroundColor,
          insetPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          titlePadding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
          contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 8.h),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          title: Row(
            children: [
              const Icon(Icons.local_printshop_rounded),
              SizedBox(width: 8.w),
              const Text('عدد النسخ'),
              const Spacer(),
              Text(
                'المدى: $min–$max',
                style: Theme.of(ctx).textTheme.labelSmall,
              ),
            ],
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // حقل الرقم مع أزرار +/-
                Row(
                  children: [
                    Expanded(
                      child: CustomTextFieldWithoutIcon(
                        textEditingController: txt,
                        height: 50,

                        keyboardType: TextInputType.number,
                        isNumeric: true,

                        // inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        onSubmitted: (p0) {
                          if (!formKey.currentState!.validate()) return;
                          syncFromText();
                          result = value;
                         OverlayService.back();
                        },
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null) return 'رقم غير صالح';
                          if (n < min || n > max) return 'القيمة يجب أن تكون بين $min و $max';
                          return null;
                        },
                        onChanged: (_) {
                          syncFromText();
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // أزرار سريعة
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('خيارات سريعة', style: Theme.of(ctx).textTheme.labelMedium),
                ),
                SizedBox(height: 6.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: <int>[1, 2, 3, 5, 10, 20, 50, 100]
                      .where((n) => n >= min && n <= max)
                      .map((n) => ChoiceChip(
                            label: Text(n.toString()),
                            selected: value == n,
                            onSelected: (_) => applyAndRefresh(n),
                          ))
                      .toList(),
                ),

                SizedBox(height: 10.h),

                // مضاعفات سريعة
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.close_fullscreen_rounded, size: 18),
                      label: const Text('×2'),
                      onPressed: () => applyAndRefresh((value * 2).clamp(min, max)),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.upgrade_rounded, size: 18),
                      label: const Text('×5'),
                      onPressed: () => applyAndRefresh((value * 5).clamp(min, max)),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('إعادة'),
                      onPressed: () => applyAndRefresh(initial),
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                Slider.adaptive(
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: (max - min) > 0 ? (max - min) : null,
                  value: value.toDouble(),
                  label: '$value',
                  onChanged: (v) => applyAndRefresh(v.round()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                OverlayService.back();
              },
              child: const Text('إلغاء'),
            ),
            AppButton(
              title: 'تأكيد الطباعة',
              iconData: Icons.print_rounded,
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                syncFromText();
                result = value;
                OverlayService.back();
              },
            )
          ],
        );
      },
    ),
  );

  return result;
}