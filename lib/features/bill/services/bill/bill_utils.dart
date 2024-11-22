import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_ui_utils.dart';

class BillUtils {
  void showExportSuccessDialog(String filePath) {
    AppUIUtils.onSuccess('تم تصدير الفواتير بنجاح!');
    Get.defaultDialog(
      title: 'تم تصدير الملف إلى:',
      radius: 8,
      contentPadding: const EdgeInsets.symmetric(horizontal: 32),
      content: Column(
        children: [
          Text(filePath),
          const VerticalSpace(16),
          ElevatedButton.icon(
            icon: const Icon(Icons.copy),
            label: const Text('نسخ المسار'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: filePath));
              AppUIUtils.onSuccess('تم نسخ المسار إلى الحافظة');
            },
          ),
        ],
      ),
    );
  }
}
