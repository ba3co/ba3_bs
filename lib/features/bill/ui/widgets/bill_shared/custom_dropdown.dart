import 'package:flutter/material.dart';

import '../../../../floating_window/managers/overlay_entry_with_priority_manager.dart';
import '../../../../floating_window/models/overlay_entry_with_priority.dart';

class CustomDropdown<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T>? onChanged;
  final String Function(T item) itemLabelBuilder;
  final double height;
  final BoxDecoration decoration;

  const CustomDropdown({
    super.key,
    this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.onChanged,
    this.height = 48.0,
    this.decoration = const BoxDecoration(),
  });

  @override
  State<CustomDropdown<T>> createState() => _CustomDropdownState<T>();
}

class _CustomDropdownState<T> extends State<CustomDropdown<T>> {
  final LayerLink _layerLink = LayerLink();
  final entryWithPriorityInstance = OverlayEntryWithPriorityManager.instance;

  OverlayEntry? overlayEntry;

  OverlayEntryWithPriority? _overlayEntryWithPriority; // Store the overlay with priority

  void _toggleDropdown() {
    if (_overlayEntryWithPriority == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    overlayEntry = _createOverlayEntry();

    // Wrap the overlay entry with priority (same instance to manage remove properly)
    _overlayEntryWithPriority = OverlayEntryWithPriority(overlayEntry: overlayEntry!, priority: 0);
    entryWithPriorityInstance.add(_overlayEntryWithPriority!);

    // Insert the overlay into the Overlay stack
    Overlay.of(context).insert(overlayEntry!);
  }

  void _removeOverlay() {
    if (overlayEntry != null) {
      if (overlayEntry!.mounted) {
        // Remove the overlay using the same instance with priority
        overlayEntry!.remove();

        // After removal, reset the stored overlay entry
        entryWithPriorityInstance.remove(_overlayEntryWithPriority!);

        // Reset the state
        _overlayEntryWithPriority = null;
      }
    }
  }

  OverlayEntry _createOverlayEntry() {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height),
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(8.0),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                shrinkWrap: true,
                children: widget.items.map((T item) {
                  return InkWell(
                    onTap: () {
                      _removeOverlay();
                      if (widget.onChanged != null) {
                        widget.onChanged!(item);
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.itemLabelBuilder(item),
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleDropdown,
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          height: widget.height,
          decoration: widget.decoration,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    widget.value != null ? widget.itemLabelBuilder(widget.value!) : "Select an option",
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.black54, // Dropdown arrow color
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }
}
