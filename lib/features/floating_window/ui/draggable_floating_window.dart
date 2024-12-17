import 'dart:developer';

import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../controllers/floating_window_controller.dart';

class DraggableFloatingWindow extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onBringToTop;
  final Offset targetPositionRatio;
  final Widget floatingWindowContent;
  final String? minimizedTitle;


  const DraggableFloatingWindow({
    super.key,
    required this.onClose,
    required this.onBringToTop,
    required this.floatingWindowContent,
    required this.targetPositionRatio,

    this.minimizedTitle,

  });

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
                              child: Column(
                                children: [
                                  Flexible(
                                    child: Visibility(
                                      visible: !controller.isMinimized,
                                      maintainState: true,
                                      child: Column(
                                        children: [
                                          InkWell(
                                            onTap: onBringToTop,
                                            child: Container(
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
                                                      child: Icon(Icons.fullscreen_outlined,
                                                          color: Colors.black, size: 12),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(child: floatingWindowContent),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (controller.isMinimized)
                                    SizedBox(
                                      width: controller.width,
                                      height: controller.height,
                                      child: Tooltip(
                                        message: minimizedTitle ?? '',
                                        textStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(fontSize: 15, color: Colors.white),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Expanded(
                                              child: IconButton(
                                                icon: Icon(Icons.keyboard_arrow_up, size: .026.sh),
                                                //  tooltip: 'اظهار',
                                                onPressed: controller.restoreWindowFromMinimized,
                                              ),
                                            ),
                                            Expanded(
                                              child: IconButton(
                                                icon: Icon(Icons.fullscreen, size: .026.sh),
                                                //   tooltip: 'تكبير',
                                                onPressed: controller.maximizeWindowFromMinimized,
                                              ),
                                            ),
                                            Expanded(
                                              child: IconButton(
                                                icon: Icon(Icons.close, size: .026.sh),
                                                // tooltip: 'اغلاق',
                                                onPressed: onClose,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              )),
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
