import 'package:flutter/material.dart';

/// Generic checklist that can handle any type of data
/// T: The type of the items
class CustomChecklist<T> extends StatefulWidget {
  final List<T> items;

  // displayed text could differ from actual saved values ( for example: display name, but the value is id)
  final String Function(T item) displayText;
  final T Function(String displayText)? valueFromText; // Optional converter
  final void Function(T item) onItemSelected;
  final void Function(T item) onItemDeselected;
  final List<T>? initiallySelected;

  const CustomChecklist({
    super.key,
    required this.items,
    required this.displayText,
    this.valueFromText,
    required this.onItemSelected,
    required this.onItemDeselected,
    this.initiallySelected,
  });

  @override
  State<CustomChecklist<T>> createState() => _CustomChecklistState<T>();
}

class _CustomChecklistState<T> extends State<CustomChecklist<T>> {
  final Map<T, bool> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    _initializeCheckedItems();
  }

  @override
  void didUpdateWidget(covariant CustomChecklist<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items ||
        oldWidget.initiallySelected != widget.initiallySelected) {
      _initializeCheckedItems();
    }
  }

  void _initializeCheckedItems() {
    _checkedItems.clear();
    for (var item in widget.items) {
      // Check if this item is in the initially selected list
      final isInitiallySelected = widget.initiallySelected?.contains(item) ?? false;
      _checkedItems[item] = isInitiallySelected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items.map((item) {
        return CheckboxListTile(
          title: Text(widget.displayText(item)),
          value: _checkedItems[item] ?? false,
          onChanged: (bool? value) {
            setState(() {
              _checkedItems[item] = value ?? false;
            });

            if (value == true) {
              widget.onItemSelected(item);
            } else {
              widget.onItemDeselected(item);
            }
          },
        );
      }).toList(),
    );
  }
}