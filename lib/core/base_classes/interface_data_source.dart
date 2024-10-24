abstract class IDataSource<T, U> {
  Future<List<T>> fetchAll();

  Future<T> fetchById(String id);

  Future<void> save(U item);

  Future<void> delete(String id);
}
