import 'package:flutter/material.dart';

class CustomChecklist extends StatefulWidget {
  final List<String> items;
  final void Function(String item) onItemSelected;
  final void Function(String item) onItemDeselected;

  const CustomChecklist({
    super.key,
    required this.items,
    required this.onItemSelected,
    required this.onItemDeselected,
  });

  @override
  State<CustomChecklist> createState() => _CustomChecklistState();
}

class _CustomChecklistState extends State<CustomChecklist> {
  final Map<String, bool> _checkedItems = {};

  @override
  void initState() {
    super.initState();
    for (var item in widget.items) {
      _checkedItems[item] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.items.map((item) {
        return CheckboxListTile(
          title: Text(item),
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
