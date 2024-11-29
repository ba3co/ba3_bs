import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/floating_window_controller.dart';

class DraggableFloatingWindow extends StatelessWidget {
  final VoidCallback onClose;
  final Widget child;
  final Offset initPosition;
  final Size initializePositionRatio;

  const DraggableFloatingWindow({
    super.key,
    required this.onClose,
    required this.child,
    required this.initPosition,
    required this.initializePositionRatio,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FloatingWindowController>(
      builder: (controller) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final newParentSize = Size(constraints.maxWidth, constraints.maxHeight);

            if (controller.parentSize.value != newParentSize) {
              controller.updateForParentSizeChange(newParentSize,
                  positionRatio: initPosition, difference: initializePositionRatio);
            }

            return GestureDetector(
              onPanUpdate: controller.isHiddenToBottom ? null : controller.onPanUpdate,
              onPanStart: controller.isHiddenToBottom ? null : controller.onPanStart,
              onPanEnd: controller.isHiddenToBottom ? null : controller.onPanEnd,
              child: Stack(
                children: [
                  Positioned(
                    left: controller.x,
                    top: controller.y,
                    child: Obx(() {
                      return MouseRegion(
                        onHover: controller.isHiddenToBottom ? null : controller.onHover,
                        cursor: controller.mouseCursor.value,
                        child: Material(
                          key: controller.floatingWindowKey,
                          elevation: 8,
                          borderRadius: BorderRadius.circular(12),
                          child: AnimatedContainer(
                            width: controller.width,
                            height: controller.height,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: controller.isHiddenToBottom
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(Icons.keyboard_arrow_up, size: .026.sh),
                                          onPressed: controller.restoreFromBottom,
                                        ),
                                      ),
                                      Expanded(
                                        child: IconButton(
                                          icon: Icon(Icons.fullscreen, size: .026.sh),
                                          onPressed: controller.restoreFromBottomToMax,
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
                                        height: 40.0,
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
                                                controller.hideToBottom(initPosition);
                                              },
                                              child: const CircleAvatar(
                                                backgroundColor: Color(0xFFFFBD44),
                                                radius: 7,
                                                child: Icon(Icons.remove, color: Colors.black, size: 12),
                                              ),
                                            ),
                                            const HorizontalSpace(),
                                            InkWell(
                                              onTap: controller.resizeToMax,
                                              child: const CircleAvatar(
                                                backgroundColor: Color(0xFF00CA4E),
                                                radius: 7,
                                                child: Icon(Icons.fullscreen_outlined, color: Colors.black, size: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(child: child),
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
