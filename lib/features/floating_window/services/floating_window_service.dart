import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../controllers/floating_window_controller.dart';

/// Service class to initializing and displaying floating windows.
class FloatingWindowService {
  /// Launches a floating window with the provided content.

  static void launchFloatingWindow(
      {required BuildContext context, required Widget floatingScreen, VoidCallback? onCloseCallback}) {
    // Initialize the floating window controller
    FloatingWindowController floatingWindowController = _initializeFloatingWindowController();

    // Get the initial target position for the floating window
    Offset targetPositionRatio = floatingWindowController.initWindowPositionManager();

    // Display the floating window
    floatingWindowController.displayFloatingWindow(
      context: context,
      floatingScreen: floatingScreen,
      targetPositionRatio: targetPositionRatio,
      onCloseCallback: onCloseCallback,
    );
  }

  /// Initializes and returns a new instance of [FloatingWindowController].
  static FloatingWindowController _initializeFloatingWindowController() {
    // Create the controller if not already created
    Get.create(() => FloatingWindowController(), permanent: false);

    // Return the controller instance
    return Get.find<FloatingWindowController>();
  }
}
