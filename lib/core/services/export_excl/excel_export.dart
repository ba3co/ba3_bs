import 'dart:typed_data';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:file_selector/file_selector.dart';

Future<void> exportJsonToExcel(List<Map<String, dynamic>> jsonList) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  if (jsonList.isNotEmpty) {
    final headers = jsonList.first.keys.toList();

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
    }

    // ✅ البيانات
    for (int row = 0; row < jsonList.length; row++) {
      for (int col = 0; col < headers.length; col++) {
        final value = jsonList[row][headers[col]];
        sheet.getRangeByIndex(row + 2, col + 1).setText(value?.toString() ?? '');
      }
    }
  }

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  // ✅ نافذة حفظ الملف
  final String? path = await getSaveLocation(suggestedName: 'exported_data.xlsx').then((value) => value?.path);
  if (path != null) {
    final file = XFile.fromData(Uint8List.fromList(bytes), name: path);
    await file.saveTo(path);
    AppUIUtils.onSuccess('✅ Saved to $path');
  } else {
    AppUIUtils.onFailure('❌ Save cancelled');
  }
}