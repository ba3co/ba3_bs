abstract class IDatabaseService<T> {
  Future<List<T>> fetchAll({required String path});

  Future<T> fetchById({required String path, String? documentId});

  Future<void> delete({required String path, String? documentId});

  Future<T> add({required String path, String? documentId, required Map<String, dynamic> data});

  Future<void> update({required String path, String? documentId, required Map<String, dynamic> data});
}
