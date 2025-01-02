import 'dart:io';
import 'package:xml/xml.dart';

abstract class IJsonImportService<T> {
  List<T> fromImportJson(Map<String, dynamic> json);
  List<T> fromImportXml(XmlDocument document);

  List<T> importFromFile(File filePath);

  List<T> importFromXmlFile(File filePath);
}
