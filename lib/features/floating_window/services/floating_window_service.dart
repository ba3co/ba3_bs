import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:flutter/cupertino.dart';

import '../controllers/floating_window_controller.dart';

/// Service class to initializing and displaying floating windows.
class FloatingWindowService {
  /// Launches a floating window with the provided content.

  static void launchFloatingWindow({
    required BuildContext context,
    required Widget floatingScreen,
    required String tag,
    String? minimizedTitle,
    VoidCallback? onCloseCallback,
    double? defaultWidth,
    double? defaultHeight,
    bool? enableResizing = true,
  }) {
    // Initialize the floating window controller
    FloatingWindowController floatingWindowController = _initializeFloatingWindowController(
        defaultWidth: defaultWidth, defaultHeight: defaultHeight, tag: tag, enableResizing: enableResizing);

    // Get the initial target position for the floating window
    Offset targetPositionRatio = floatingWindowController.initWindowPositionManager();

    // Display the floating window
    floatingWindowController.displayFloatingWindow(
      context: context,
      tag: tag,
      floatingScreen: floatingScreen,
      targetPositionRatio: targetPositionRatio,
      onCloseCallback: onCloseCallback,
      minimizedTitle: minimizedTitle,
    );
  }

  /// Initializes and returns a new instance of [FloatingWindowController].
  static FloatingWindowController _initializeFloatingWindowController(
          {double? defaultWidth, double? defaultHeight, String? tag, bool? enableResizing}) =>
      put(FloatingWindowController(defaultWidth: defaultWidth, defaultHeight: defaultHeight, enableResizing: enableResizing),
          tag: tag);
}
