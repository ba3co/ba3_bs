import 'package:flutter/material.dart';

import '../../../features/floating_window/services/floating_window_service.dart';

mixin FloatingLauncher {
  /// Launches a floating window with a specified widget.
  void launchFloatingWindow({
    required BuildContext context,
    required Widget floatingScreen,
    String? minimizedTitle,
    VoidCallback? onCloseCallback,
  }) {
    FloatingWindowService.launchFloatingWindow(
      context: context,
      onCloseCallback: onCloseCallback,
      floatingScreen: floatingScreen,
      minimizedTitle: minimizedTitle,
    );
  }
}
