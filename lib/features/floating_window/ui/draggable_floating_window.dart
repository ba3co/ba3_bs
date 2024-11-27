import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/floating_window_controller.dart';

class DraggableFloatingWindow extends StatelessWidget {
  final VoidCallback onClose;
  final Widget child;

  const DraggableFloatingWindow({super.key, required this.onClose, required this.child});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FloatingWindowController>(
      builder: (controller) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final newParentSize = Size(constraints.maxWidth, constraints.maxHeight);

            // Rebuild window position and size if the parent size changes
            if (controller.parentSize.value != newParentSize) {
              controller.updateForParentSizeChange(newParentSize);
            }
            return GestureDetector(
              onPanUpdate: controller.onPanUpdate,
              onPanStart: controller.onPanStart,
              onPanEnd: controller.onPanEnd,
              child: Stack(
                children: [
                  Positioned(
                    left: controller.x,
                    top: controller.y,
                    child: Obx(() {
                      return MouseRegion(
                        onHover: controller.onHover,
                        cursor: controller.currentCursor.value,
                        child: Material(
                          key: controller.floatingWindowKey,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: controller.width,
                            height: controller.height,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: onClose,
                                  ),
                                ),
                                child,
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
