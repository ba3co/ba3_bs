import 'package:flutter/material.dart';

import '../../features/floating_window/managers/overlay_entry_with_priority_manager.dart';

class CustomDropdownOverly<T> extends StatefulWidget {
  final T? value;
  final List<T> items;
  final ValueChanged<T>? onChanged;
  final String Function(T item) itemLabelBuilder;
  final double? height;
  final BoxDecoration? decoration;
  final int? priority;
  final VoidCallback? onCloseCallback;
  final VoidCallback back;
  final OverlayEntryWithPriorityManager overlayEntryWithPriorityInstance;

  const CustomDropdownOverly({
    super.key,
    required this.overlayEntryWithPriorityInstance,
    this.value,
    required this.items,
    required this.itemLabelBuilder,
    this.onChanged,
    this.height,
    this.decoration,
    this.priority,
    required this.back,
    this.onCloseCallback,
  });

  @override
  State<CustomDropdownOverly<T>> createState() => _CustomDropdownOverlyState<T>();
}

class _CustomDropdownOverlyState<T> extends State<CustomDropdownOverly<T>> {
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? overlayEntry;

  void _toggleDropdown() {
    if (overlayEntry == null) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _showOverlay() {
    final OverlayState overlayState = Overlay.of(context);

    overlayEntry = _createOverlayEntry();

    // Display the overlay using the OverlayEntryWithPriorityManager with priority management
    widget.overlayEntryWithPriorityInstance.displayOverlay(
      overlay: overlayState,
      overlayEntry: overlayEntry,
      content: const SizedBox(),
      priority: widget.priority,
      onCloseCallback: () {
        widget.onCloseCallback?.call();
        overlayEntry = null;
      },
    );
  }

  void _removeOverlay() {
    if (overlayEntry != null && overlayEntry!.mounted) {
      widget.back();
    }
  }

  Widget _buildDropdownContent() {
    return ListView(
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
    );
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
              child: _buildDropdownContent(),
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
          height: widget.height ?? 48.0,
          decoration: widget.decoration ?? const BoxDecoration(),
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
