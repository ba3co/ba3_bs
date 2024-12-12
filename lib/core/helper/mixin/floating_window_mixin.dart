import 'package:flutter/material.dart';

import '../../../features/floating_window/services/floating_window_service.dart';

mixin FloatingWindowMixin {
  void launchFloatingWindow({
    required BuildContext context,
    required Widget floatingScreen,
    VoidCallback? onCloseCallback,
  }) {
    // Launch the floating window with the AddBillScreen
    FloatingWindowService.launchFloatingWindow(
      context: context,
      onCloseCallback: onCloseCallback,
      floatingScreen: floatingScreen,
    );
  }
}
