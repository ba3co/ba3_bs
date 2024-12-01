import 'dart:async';
import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/features/floating_window/controllers/window_position_manager.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../ui/draggable_floating_window.dart';

class FloatingWindowController extends GetxController {
  // Get the singleton instance of WindowPositionManager
  WindowPositionManager windowPositionManager = WindowPositionManager.instance;

  FloatingWindowController() {
    log('call FloatingWindowController constructor');
    _initializeWindow();
  }

  late double x, y, width, height;

  final double minWidth = 750.0, minHeight = 400.0, edgeSize = 5.0;

  final parentSize = Rx<Size>(Size.zero);

  final GlobalKey floatingWindowKey = GlobalKey();

  Timer? _resizeDebounceTimer;

  Timer? _windowSizeChangeDebounceTimer;

  Offset? resizeStartPosition;

  bool isResizing = false;

  var mouseCursor = SystemMouseCursors.basic.obs;

  double bottomWindowWidthRatio = AppConstants.bottomWindowWidth / AppConstants.deviceFullWidth;

  double bottomWindowHeightRatio = AppConstants.bottomWindowHeight / AppConstants.deviceFullHeight;

  // New State to Handle Minimized State
  bool isMinimized = false;

  void _initializeWindow() {
    width = 0.7.sw;
    height = 0.8.sh;

    x = (1.sw - width) / 2;
    y = (1.sh - height) / 2;

    parentSize.value = Size(1.sw, 1.sh);
  }

  Offset initWindowPositionManager() {
    final double windowWidth = bottomWindowWidthRatio * parentSize.value.width; // Width for the minimized container
    final double windowHeight = bottomWindowHeightRatio * parentSize.value.height; // Height for the minimized container

    final targetPositionRatio = windowPositionManager.getNextWindowPositionRatio(
        windowWidth, windowHeight, parentSize.value.width, parentSize.value.height);

    return targetPositionRatio;
  }

  void updateWindowForSizeChange({
    required Size newParentSize,
    required Offset positionRatio,
  }) {
    // Cancel the previous timer if it exists
    _windowSizeChangeDebounceTimer?.cancel();

    // Start a new timer
    _windowSizeChangeDebounceTimer = Timer(const Duration(milliseconds: 80), () {
      if (isMinimized) {
        _updateMinimizedState(newParentSize, positionRatio);
      } else {
        _updateMaximizedState(newParentSize);
      }

      // Update the parent size and refresh the UI
      parentSize.value = newParentSize;
      update();
    });
  }

  void _updateMaximizedState(Size newParentSize) {
    width = newParentSize.width * 0.7;
    height = newParentSize.height * 0.8;

    x = (newParentSize.width - width) / 2;
    y = (newParentSize.height - height) / 2;
  }

  void _updateMinimizedState(Size newParentSize, Offset positionRatio) {
    width = bottomWindowWidthRatio * newParentSize.width; // Width for the minimized container
    height = bottomWindowHeightRatio * newParentSize.height; // Height for the minimized container

    x = positionRatio.dx * newParentSize.width;
    y = positionRatio.dy * newParentSize.height;

    log('newParentSize width on updateForParentSizeChange: ${newParentSize.width}');
    log('newParentSize height on updateForParentSizeChange: ${newParentSize.height}');
  }

  /// Resize to 95% of the parent container
  void maximize() {
    width = parentSize.value.width * 0.95;
    height = parentSize.value.height * 0.95;

    // Ensure the window stays within bounds
    x = x.clamp(0, parentSize.value.width - width);
    y = y.clamp(0, parentSize.value.height - height);

    update();
  }

  /// Resize to the minimum allowed size
  void resizeToMin() {
    width = minWidth;
    height = minHeight;

    // Ensure the window stays within bounds
    x = x.clamp(0, parentSize.value.width - width);
    y = y.clamp(0, parentSize.value.height - height);

    update();
  }

  void minimize(Offset position) {
    isMinimized = true;

    width = bottomWindowWidthRatio * parentSize.value.width; // Width for the minimized container
    height = bottomWindowHeightRatio * parentSize.value.height; // Height for the minimized container

    x = position.dx * parentSize.value.width;
    y = position.dy * parentSize.value.height;

    update();
  }

  void restoreWindowFromMinimized() {
    isMinimized = false;
    _initializeWindow();
    update();
  }

  void maximizeWindowFromMinimized() {
    isMinimized = false;
    maximize();
    update();
  }

  void displayFloatingWindow(
      {required BuildContext context, required Widget child, required Offset targetPositionRatio}) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return DraggableFloatingWindow(
          onClose: () {
            overlayEntry.remove();
            windowPositionManager.removeWindowPosition(targetPositionRatio);
          },
          targetPositionRatio: targetPositionRatio,
          floatingWindowContent: child,
        );
      },
    );

    overlay.insert(overlayEntry);
  }

  Offset _getLocalPosition(Offset globalPosition) {
    final RenderBox renderBox = floatingWindowKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }

  void move(DragUpdateDetails details, double screenWidth, double screenHeight) {
    x += details.delta.dx;
    y += details.delta.dy;
    x = x.clamp(0, screenWidth - width);
    y = y.clamp(0, screenHeight - height);
    update();
  }

  void resize(DragUpdateDetails details, double screenWidth, double screenHeight) {
    // Immediate visual update
    _applyResizeLogic(details, screenWidth, screenHeight);
    update();

    // Debounced constraints enforcement
    _resizeDebounceTimer?.cancel();
    _resizeDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      _applyConstraints(screenWidth, screenHeight);
      update();
    });
  }

  void _applyResizeLogic(DragUpdateDetails details, double screenWidth, double screenHeight) {
    final dx = details.delta.dx;
    final dy = details.delta.dy;

    if (resizeStartPosition == null) return;

    if (_isOnLeftEdge(resizeStartPosition!)) {
      final newWidth = width - dx;
      if (newWidth >= minWidth && newWidth <= screenWidth * .95) {
        width = newWidth;
        x += dx;
      }
    }
    if (_isOnRightEdge(details.localPosition) && !_isOnLeftEdge(resizeStartPosition!)) {
      final newWidth = width + dx;
      if (newWidth >= minWidth && newWidth <= screenWidth * .95) {
        width = newWidth;
      }
    }
    if (_isOnTopEdge(resizeStartPosition!)) {
      final newHeight = height - dy;
      if (newHeight >= minHeight && newHeight <= screenHeight * .95) {
        height = newHeight;
        y += dy;
      }
    }
    if (_isOnBottomEdge(details.localPosition) && !_isOnTopEdge(resizeStartPosition!)) {
      final newHeight = height + dy;
      if (newHeight >= minHeight && newHeight <= screenHeight * .95) {
        height = newHeight;
      }
    }
  }

  void _applyConstraints(double screenWidth, double screenHeight) {
    width = width.clamp(minWidth, screenWidth - x);
    height = height.clamp(minHeight, screenHeight - y);
    x = x.clamp(0, screenWidth - width);
    y = y.clamp(0, screenHeight - height);
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (isResizing) {
      resize(details, parentSize.value.width, parentSize.value.height);
    } else {
      move(details, parentSize.value.width, parentSize.value.height);
    }
  }

  void onPanStart(DragStartDetails details) {
    final Offset localPosition = _getLocalPosition(details.globalPosition);
    if (isOnEdge(localPosition)) {
      isResizing = true;
      resizeStartPosition = localPosition;
    } else {
      isResizing = false;
    }
  }

  void onPanEnd(DragEndDetails details) {
    isResizing = false;
    resizeStartPosition = null;
  }

  void onHover(PointerHoverEvent event) {
    final Offset localPosition = _getLocalPosition(event.position);
    _updateCursor(localPosition);
  }

  void _updateCursor(Offset position) {
    if (_isOnTopLeftCorner(position) || _isOnBottomRightCorner(position)) {
      mouseCursor.value = SystemMouseCursors.resizeUpLeftDownRight;
    } else if (_isOnTopRightCorner(position) || _isOnBottomLeftCorner(position)) {
      mouseCursor.value = SystemMouseCursors.resizeUpRightDownLeft;
    } else if (_isOnLeftEdge(position) || _isOnRightEdge(position)) {
      mouseCursor.value = SystemMouseCursors.resizeLeftRight;
    } else if (_isOnTopEdge(position) || _isOnBottomEdge(position)) {
      mouseCursor.value = SystemMouseCursors.resizeUpDown;
    } else {
      mouseCursor.value = SystemMouseCursors.move;
    }
  }

  bool isOnEdge(Offset position) =>
      _isOnCorner(position) ||
      _isOnRightEdge(position) ||
      _isOnLeftEdge(position) ||
      _isOnTopEdge(position) ||
      _isOnBottomEdge(position);

  bool _isOnRightEdge(Offset position) => position.dx >= width - edgeSize;

  bool _isOnLeftEdge(Offset position) => position.dx <= edgeSize;

  bool _isOnTopEdge(Offset position) => position.dy <= edgeSize;

  bool _isOnBottomEdge(Offset position) => position.dy >= height - edgeSize;

  bool _isOnCorner(Offset position) =>
      (_isOnLeftEdge(position) || _isOnRightEdge(position)) && (_isOnTopEdge(position) || _isOnBottomEdge(position));

  bool _isOnTopLeftCorner(Offset position) => _isOnLeftEdge(position) && _isOnTopEdge(position);

  bool _isOnTopRightCorner(Offset position) => _isOnRightEdge(position) && _isOnTopEdge(position);

  bool _isOnBottomLeftCorner(Offset position) => _isOnLeftEdge(position) && _isOnBottomEdge(position);

  bool _isOnBottomRightCorner(Offset position) => _isOnRightEdge(position) && _isOnBottomEdge(position);
}
