import 'dart:convert';
import 'dart:io';

import 'package:xml/xml.dart';

import 'i_import_service.dart';

abstract class ImportServiceBase<T> implements IImportService<T> {
  /// Abstract method to be implemented by subclasses for JSON parsing
  @override
  List<T> fromImportJson(Map<String, dynamic> json);

  @override
  List<T> fromImportXml(XmlDocument document);

  @override
  List<T> importFromFile(File filePath) {
    // final File file = File(filePath);
    final jsonContent = jsonDecode(filePath.readAsStringSync()) as Map<String, dynamic>;
    return fromImportJson(jsonContent);
  }

  @override
  List<T> importFromXmlFile(File filePath) {
    final xmlContent = filePath.readAsStringSync();
    final XmlDocument document = XmlDocument.parse(xmlContent);

    return fromImportXml(document);
  }
}
