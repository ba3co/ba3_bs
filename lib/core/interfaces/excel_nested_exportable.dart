abstract class ExcelNestedExportable {
  /// Parent row (bill-level)
  Map<String, dynamic> buildParentExcelRow(List<String> fields);

  /// Child rows (item-level)
  List<Map<String, dynamic>> buildChildExcelRows(List<String> fields);
}
