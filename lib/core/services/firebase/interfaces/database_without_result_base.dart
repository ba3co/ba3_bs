abstract class DatabaseWithoutResultBase<T> {
  Future<List<T>> fetchAll();

  Future<T> fetchById(String id);

  Future<void> delete(String id);

  Future<void> save(T item);
}
