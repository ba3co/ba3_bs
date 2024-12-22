abstract class IDatabaseService<T> {
  Future<List<T>> fetchAll({required String path});

  Future<List<T>> fetchByField({required String path, required String field, required String value});

  Future<T> fetchById({required String path, String? documentId});

  Future<void> delete({required String path, String? documentId});

  Future<T> add({required String path, String? documentId, required Map<String, dynamic> data});

  Future<void> update({required String path, String? documentId, required Map<String, dynamic> data});

  Future<List<Map<String, dynamic>>> addAll({required String path, required List<Map<String, dynamic>> data});
}
