abstract class IJsonExportService<T> {
  Map<String, dynamic> toExportJson(List<T> itemsModels);

  Future<void> exportToFile(List<T> itemsModels);
}
