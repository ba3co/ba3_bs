import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../ui/draggable_floating_window.dart';

class FloatingWindowController extends GetxController {
  late double x, y, width, height;
  final double minWidth = 200.0, minHeight = 200.0, edgeSize = 5.0;
  bool isResizing = false;
  Offset? resizeStartPosition;
  var currentCursor = SystemMouseCursors.basic.obs;

  final parentSize = Rx<Size>(Size.zero);

  final GlobalKey floatingWindowKey = GlobalKey();

  FloatingWindowController() {
    _initializeWindow();
  }

  void _initializeWindow() {
    width = 1.sw * 0.7;
    height = 1.sh * 0.8;
    x = (1.sw - width) / 2;
    y = (1.sh - height) / 2;
    parentSize.value = Size(1.sw, 1.sh);
  }

  void showFloatingWindow({required BuildContext context, required Widget child}) {
    final overlay = Overlay.of(context);

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        return DraggableFloatingWindow(
          onClose: () {
            overlayEntry.remove();
          },
          child: child,
        );
      },
    );

    overlay.insert(overlayEntry);
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (isResizing) {
      resizeWindow(details, parentSize.value.width, parentSize.value.height);
    } else {
      moveWindow(details, parentSize.value.width, parentSize.value.height);
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

  void updateForParentSizeChange(Size newParentSize) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      width = newParentSize.width * 0.7;
      height = newParentSize.height * 0.8;

      x = (newParentSize.width - width) / 2;
      y = (newParentSize.height - height) / 2;

      parentSize.value = newParentSize;
      update();
    });
  }

  Offset _getLocalPosition(Offset globalPosition) {
    final RenderBox renderBox = floatingWindowKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }

  void moveWindow(DragUpdateDetails details, double screenWidth, double screenHeight) {
    x += details.delta.dx;
    y += details.delta.dy;
    x = x.clamp(0, screenWidth - width);
    y = y.clamp(0, screenHeight - height);
    update();
  }

  Timer? debounceTimer;

  void resizeWindow(DragUpdateDetails details, double screenWidth, double screenHeight) {
    // Immediate visual update
    _applyResizeLogic(details, screenWidth, screenHeight);
    update();

    // Debounced constraints enforcement
    debounceTimer?.cancel();
    debounceTimer = Timer(const Duration(milliseconds: 100), () {
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

  void onHover(PointerHoverEvent event) {
    final Offset localPosition = _getLocalPosition(event.position);
    _updateCursor(localPosition);
  }

  void _updateCursor(Offset position) {
    if (_isOnTopLeftCorner(position)) {
      currentCursor.value = SystemMouseCursors.resizeUpLeftDownRight;
    } else if (_isOnTopRightCorner(position)) {
      currentCursor.value = SystemMouseCursors.resizeUpRightDownLeft;
    } else if (_isOnBottomLeftCorner(position)) {
      currentCursor.value = SystemMouseCursors.resizeUpRightDownLeft;
    } else if (_isOnBottomRightCorner(position)) {
      currentCursor.value = SystemMouseCursors.resizeUpLeftDownRight;
    } else if (_isOnRightEdge(position)) {
      currentCursor.value = SystemMouseCursors.resizeLeftRight;
    } else if (_isOnBottomEdge(position)) {
      currentCursor.value = SystemMouseCursors.resizeUpDown;
    } else if (_isOnLeftEdge(position)) {
      currentCursor.value = SystemMouseCursors.resizeLeftRight;
    } else if (_isOnTopEdge(position)) {
      currentCursor.value = SystemMouseCursors.resizeUpDown;
    } else {
      currentCursor.value = SystemMouseCursors.move;
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
