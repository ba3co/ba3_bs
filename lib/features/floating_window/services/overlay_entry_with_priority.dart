import 'package:flutter/cupertino.dart';

class OverlayEntryWithPriority {
  final OverlayEntry overlayEntry;
  final int priority;

  OverlayEntryWithPriority({
    required this.overlayEntry,
    this.priority = 1,
  });
}

class OverlayEntryWithPriorityManager {
  // Private constructor to prevent external instantiation
  OverlayEntryWithPriorityManager._();

  // The single instance of the manager
  static final OverlayEntryWithPriorityManager instance = OverlayEntryWithPriorityManager._();

  // Store the overlay entries with priority
  final List<OverlayEntryWithPriority> overlayEntries = [];

  add(OverlayEntryWithPriority overlayEntryWithPriority) {
    overlayEntries.add(overlayEntryWithPriority);
  }

  remove(OverlayEntryWithPriority overlayEntryWithPriority) {
    overlayEntries.remove(overlayEntryWithPriority);
  }
}
