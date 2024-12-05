import 'package:flutter/material.dart';

import '../../../core/widgets/custom_dropdown_overly.dart';
import '../managers/overlay_entry_with_priority_manager.dart';

class OverlayService {
  static final _entryWithPriorityInstance = OverlayEntryWithPriorityManager.instance;

  static void back() {
    _entryWithPriorityInstance.dispose();
  }

  static void showOverlayDialog({
    required BuildContext context,
    required Widget content,
    String? title,
    double? width,
    double? height,
    int? priority,
    VoidCallback? onCloseCallback,
  }) {
    final OverlayState overlayState = Overlay.of(context);

    _entryWithPriorityInstance.displayOverlay(
      overlay: overlayState,
      title: title,
      content: content,
      width: width,
      height: height,
      priority: priority,
      onCloseCallback: onCloseCallback,
    );
  }

  static Widget showOverlayDropdown<T>({
    required T? value,
    required List<T> items,
    required ValueChanged<T>? onChanged,
    required String Function(T item) itemLabelBuilder,
    double? height,
    BoxDecoration? decoration,
    int? priority,
    VoidCallback? onCloseCallback,
  }) {
    return CustomDropdownOverly<T>(
      overlayEntryWithPriorityInstance: _entryWithPriorityInstance,
      value: value,
      items: items,
      itemLabelBuilder: itemLabelBuilder,
      onChanged: onChanged,
      height: height,
      decoration: decoration,
      priority: priority,
      back: back,
      onCloseCallback: onCloseCallback,
    );
  }
}
