import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_checklist.dart';


class SelectableChecklistSection<T> extends StatelessWidget {
  const SelectableChecklistSection({
    super.key,
    required this.title,
    required this.items,
    required this.displayText,
    required this.initiallySelected,
    required this.isAllSelected,
    required this.onSelectAll,
    required this.onUnselectAll,
    required this.onItemSelected,
    required this.onItemDeselected,
  });

  final String title;
  final List<T> items;
  final List<T> initiallySelected;

  final String Function(T item) displayText;

  final bool isAllSelected;
  final VoidCallback onSelectAll;
  final VoidCallback onUnselectAll;

  final void Function(T item) onItemSelected;
  final void Function(T item) onItemDeselected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Row(
              children: [
                Text(AppStrings.selectAll.tr),
                Checkbox(
                  value: isAllSelected,
                  onChanged: (value) {
                    if (value == true) {
                      onSelectAll();
                    } else {
                      onUnselectAll();
                    }
                  },
                ),
              ],
            ),
          ],
        ),
        CustomChecklist<T>(
          items: items,
          initiallySelected: initiallySelected,
          displayText: displayText,
          onItemSelected: onItemSelected,
          onItemDeselected: onItemDeselected,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
