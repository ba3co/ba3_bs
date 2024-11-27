import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'floating_window_controller.dart';

class FloatingWindowManager {
  void createNewFloatingWindow({
    required BuildContext context,
    required Widget child,
  }) {
    FloatingWindowController floatingWindowController = _createNewFloatingWindowController();
    floatingWindowController.showFloatingWindow(context: context, child: child);
  }

  FloatingWindowController _createNewFloatingWindowController() {
    // Create a new instance of FloatingWindowController every time
    Get.create(() => FloatingWindowController(), permanent: false);
    return Get.find<FloatingWindowController>();
  }
}
