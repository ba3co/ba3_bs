import '../models/overlay_entry_with_priority.dart';

/// Manages a list of overlay entries with associated priorities.
class OverlayEntryWithPriorityManager {
  /// Private constructor to prevent external instantiation.
  OverlayEntryWithPriorityManager._();

  /// The singleton instance of the manager.
  static final OverlayEntryWithPriorityManager instance = OverlayEntryWithPriorityManager._();

  /// Stores overlay entries; lower priority numbers indicate higher importance.
  final List<OverlayEntryWithPriority> overlayEntries = [];

  /// Adds an overlay entry with a specified priority.
  void add(OverlayEntryWithPriority overlayEntryWithPriority) {
    overlayEntries.add(overlayEntryWithPriority);
  }

  /// Removes a specific overlay entry.
  void remove(OverlayEntryWithPriority overlayEntryWithPriority) {
    overlayEntries.remove(overlayEntryWithPriority);
  }
}
