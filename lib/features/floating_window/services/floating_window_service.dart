import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../controllers/floating_window_controller.dart';

class FloatingWindowService {
  static void launchFloatingWindow({required BuildContext context, required Widget child}) {
    FloatingWindowController floatingWindowController = _initializeFloatingWindowController();

    Offset targetPositionRatio = floatingWindowController.initWindowPositionManager();

    floatingWindowController.displayFloatingWindow(
        context: context, child: child, targetPositionRatio: targetPositionRatio);
  }

  static FloatingWindowController _initializeFloatingWindowController() {
    Get.create(() => FloatingWindowController(), permanent: false);

    return Get.find<FloatingWindowController>();
  }
}
