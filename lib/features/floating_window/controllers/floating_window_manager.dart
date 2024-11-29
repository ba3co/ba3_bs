import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'floating_window_controller.dart';

class FloatingWindowManager {
  void createNewFloatingWindow({
    required BuildContext context,
    required Widget child,
  }) {
    FloatingWindowController floatingWindowController = _createNewFloatingWindowController();

    ({Offset initPosition, Size initializePositionRatio}) position =
        floatingWindowController.initWindowPositionManager();

    floatingWindowController.showFloatingWindow(
      context: context,
      child: child,
      initPosition: position.initPosition,
      initializePositionRatio: position.initializePositionRatio,
    );
  }

  FloatingWindowController _createNewFloatingWindowController() {
    if (Get.isRegistered<FloatingWindowController>()) {
      return Get.find<FloatingWindowController>();
    }
    log('create FloatingWindowController');
    Get.create(() => FloatingWindowController(), permanent: false);
    log('find FloatingWindowController');
    return Get.find<FloatingWindowController>();
  }
}
