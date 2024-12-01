import 'dart:developer';

import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/floating_window_controller.dart';

class DraggableFloatingWindow extends StatelessWidget {
  final VoidCallback onClose;
  final Offset targetPositionRatio;
  final Widget floatingWindowContent;

  const DraggableFloatingWindow(
      {super.key, required this.onClose, required this.floatingWindowContent, required this.targetPositionRatio});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FloatingWindowController>(
      builder: (controller) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final newParentSize = Size(constraints.maxWidth, constraints.maxHeight);

            if (controller.parentSize.value != newParentSize) {
              log('controller.parentSize.value != newParentSize');
              controller.updateWindowForSizeChange(newParentSize: newParentSize, positionRatio: targetPositionRatio);
            }

            return GestureDetector(
              onPanUpdate: controller.isMinimized ? null : controller.onPanUpdate,
              onPanStart: controller.isMinimized ? null : controller.onPanStart,
              onPanEnd: controller.isMinimized ? null : controller.onPanEnd,
              child: Stack(
                children: [
                  Positioned(
                    left: controller.x,
                    top: controller.y,
                    child: Obx(() {
                      return MouseRegion(
                        onHover: controller.isMinimized ? null : controller.onHover,
                        cursor: controller.mouseCursor.value,
                        child: Material(
                          key: controller.floatingWindowKey,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: controller.width,
                            height: controller.height,
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: controller.isMinimized
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(Icons.keyboard_arrow_up, size: .026.sh),
                                          onPressed: controller.restoreWindowFromMinimized,
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(Icons.fullscreen, size: .026.sh),
                                          onPressed: controller.maximizeWindowFromMinimized,
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(Icons.close, size: .026.sh),
                                          onPressed: onClose,
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFF2C2C2E),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(8.0),
                                            topRight: Radius.circular(8.0),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            const HorizontalSpace(),
                                            InkWell(
                                              onTap: onClose,
                                              child: const CircleAvatar(
                                                backgroundColor: Color(0xFFFF605C),
                                                radius: 7,
                                                child: Icon(Icons.close, color: Colors.black, size: 12),
                                              ),
                                            ),
                                            const HorizontalSpace(),
                                            InkWell(
                                              onTap: () {
                                                controller.minimize(targetPositionRatio);
                                              },
                                              child: const CircleAvatar(
                                                backgroundColor: Color(0xFFFFBD44),
                                                radius: 7,
                                                child: Icon(Icons.remove, color: Colors.black, size: 12),
                                              ),
                                            ),
                                            const HorizontalSpace(),
                                            InkWell(
                                              onTap: controller.maximize,
                                              child: const CircleAvatar(
                                                backgroundColor: Color(0xFF00CA4E),
                                                radius: 7,
                                                child: Icon(Icons.fullscreen_outlined, color: Colors.black, size: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: floatingWindowContent), // This stays as it is.
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
