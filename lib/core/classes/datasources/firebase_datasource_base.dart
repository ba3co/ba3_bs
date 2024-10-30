abstract class FirebaseDatasourceBase<T> {
  Future<List<T>> fetchAll();

  Future<T> fetchById(String id);

  Future<void> save(T item);

  Future<void> delete(String id);
}
