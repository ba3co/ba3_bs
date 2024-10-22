import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

class LoginController extends GetxController with WindowListener {
  RxBool isWindowClosePrevented = false.obs;

  @override
  void onInit() {
    super.onInit();
    windowManager.addListener(this);
    _initWindowSettings();
  }

  @override
  void onClose() {
    windowManager.removeListener(this);
    super.onClose();
  }

  Future<void> _initWindowSettings() async {
    await windowManager.setPreventClose(true);
    isWindowClosePrevented.value = true;
  }

  Future<bool> showMacOSExitConfirmationDialog() async {
    return await showDialog<bool>(
          context: Get.context!,
          builder: (BuildContext context) {
            return SizedBox(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // Rounded corners
                ),
                elevation: 16,
                backgroundColor: Colors.white, // Set background color
                child: SizedBox(
                  width: 50,
                  height: 240,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Padding around the dialog
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FlutterLogo(size: 50), // Flutter logo at the top
                        const SizedBox(height: 16), // Spacing
                        const Text(
                          'Are you sure you want to close this window?',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), // Bold title
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8), // Spacing
                        const Text(
                          'Any unsaved changes will be lost.',
                          style: TextStyle(color: Colors.grey, fontSize: 14), // Subtext in grey
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24), // Spacing
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Get.back(result: true); // Close confirmed
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue, // Blue button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // Rounded button
                                ),
                              ),
                              child: const Text('Close'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Get.back(result: false); // Close canceled
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey, // Grey button color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8), // Rounded button
                                ),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ) ??
        false; // Return false if dialog is dismissed
  }

  @override
  Future<void> onWindowClose() async {
    bool isPreventClose = await windowManager.isPreventClose();

    if (isPreventClose) {
      // Show the custom macOS-like exit confirmation dialog
      bool shouldClose = await showMacOSExitConfirmationDialog();

      if (shouldClose) {
        await windowManager.destroy(); // Close the window
      } else {
        await windowManager.setPreventClose(true); // Re-enable close prevention
      }
    } else {
      await windowManager.destroy(); // Close the window without confirmation
    }
  }
}
