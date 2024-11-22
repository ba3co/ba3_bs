abstract class IFirebaseDatasource<T> {
  Future<List<T>> fetchAll();

  Future<T> fetchById(String id);

  Future<void> delete(String id);
}
