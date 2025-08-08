import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/widgets/app_button.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

class AddressDialogWidget extends StatelessWidget {
  final void Function(String password) onConfirm;
  final String? title;

  const AddressDialogWidget({
    super.key,
    required this.onConfirm,
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
            Text(title ?? 'أدخل العنوان', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            VerticalSpace( 12),
            TextField(
              controller: controller,
              onSubmitted: onConfirm,
              decoration: InputDecoration(
                hintText: 'عنوان المستلم',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            VerticalSpace( 16),
            Center(
              child: AppButton(
                width: 60,
                height: 20,
                iconData: FontAwesomeIcons.check,
                onPressed: () => onConfirm(controller.text),
                title: AppStrings.confirm.tr,
              ),
            ),
          ],
        ),
      ),
    );
  }
}