import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/sellers/ui/widgets/date_range_picker.dart';
import '../styling/app_colors.dart';
import '../widgets/app_button.dart';
import '../constants/app_strings.dart';

class ChooseStartEndDateDialog extends StatefulWidget {
  final dynamic pickedDateRange;
  final void Function(dynamic value) onSelectionChanged;
  final VoidCallback onSubmit;
  final String? title;

  const ChooseStartEndDateDialog({
    super.key,
    required this.pickedDateRange,
    required this.onSelectionChanged,
    required this.onSubmit,
    this.title,
  });

  @override
  State<ChooseStartEndDateDialog> createState() => _ChooseStartEndDateDialogState();
}

class _ChooseStartEndDateDialogState extends State<ChooseStartEndDateDialog> {
  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: AppColors.lightBlueColor,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      widget.title ?? AppStrings.viewOptions.tr,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    DateRangePicker(
                      onSubmit: widget.onSubmit,
                      pickedDateRange: widget.pickedDateRange,
                      onSelectionChanged: (args) {
                        widget.onSelectionChanged(args.value);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              AppButton(
                title: AppStrings.confirm.tr,
                iconData: Icons.check,
                onPressed: widget.onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}