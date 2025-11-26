// Replace your entire CustomDropDown with this modern version

import 'package:flutter/material.dart';

import '../styling/app_colors.dart';

class CustomDropDown extends StatelessWidget {
  final String? value;
  final List<String> listValue;
  final String label;
  final Function(String?) onChange;
  final bool enabled;

  const CustomDropDown({
    super.key,
    required this.value,
    required this.listValue,
    required this.label,
    required this.onChange,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      width: 250,
      enabled: enabled,
      hintText: label,
      initialSelection: value?.isNotEmpty == true ? value : null,
      dropdownMenuEntries: listValue.map((e) {
        return DropdownMenuEntry(value: e, label: e);
      }).toList(),
      onSelected: onChange,

      // Styling to match your old design
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        constraints: const BoxConstraints(maxHeight: 56),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.grayColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.lightBlueColor, width: 2),
        ),
      ),

      menuStyle: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(8),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}