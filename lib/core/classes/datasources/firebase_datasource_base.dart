abstract class FirebaseDatasourceBase<T> {
  Future<List<T>> fetchAll();

  Future<T> fetchById(String id);

  Future<void> save(Map<String, dynamic> item);

  Future<void> delete(String id);
}
