import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'i_json_export_service.dart';

abstract class BaseJsonExportService<T> implements IJsonExportService<T> {
  /// Abstract method to be implemented by subclasses for JSON conversion
  @override
  Map<String, dynamic> toExportJson(List<T> itemsModels);

  /// Shared method for exporting JSON data to a file
  @override
  Future<void> exportToFile(List<T> itemsModels) async {
    final Directory documentsDirectory = await getApplicationDocumentsDirectory();
    final String filePath = '${documentsDirectory.path}/exported_data.json';

    final File file = File(filePath);
    final jsonContent = jsonEncode(toExportJson(itemsModels));

    await file.writeAsString(jsonContent);

    log('File exported to: $filePath');
  }
}
