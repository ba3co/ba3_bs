import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class PasswordDialogWidget extends StatelessWidget {
  final void Function(String password) onConfirm;
  final VoidCallback onCancel;
  final String? title;

  const PasswordDialogWidget({
    super.key,
    required this.onConfirm,
    required this.onCancel,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title ?? 'أدخل كلمة السر', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            VerticalSpace( 12),
            TextField(
              controller: controller,
              obscureText: true,
              onSubmitted: onConfirm,
              decoration: InputDecoration(
                hintText: 'كلمة السر',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            VerticalSpace( 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppButton(
                  onPressed: onCancel,
                  width: 60,
                  color: Colors.redAccent,
                  height: 20,
                  iconData: FontAwesomeIcons.cancel,
                  title: AppStrings.cancel.tr,
                ),
                HorizontalSpace(),
                AppButton(
                  width: 60,
                  height: 20,
                  iconData: FontAwesomeIcons.check,
                  onPressed: () => onConfirm(controller.text),
                  title: AppStrings.confirm.tr,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}