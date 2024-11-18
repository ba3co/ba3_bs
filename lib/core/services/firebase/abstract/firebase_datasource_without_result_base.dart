import 'i_firebase_datasource.dart';

abstract class FirebaseDatasourceWithoutResultBase<T> implements IFirebaseDatasource<T> {
  @override
  Future<List<T>> fetchAll();

  @override
  Future<T> fetchById(String id);

  @override
  Future<void> delete(String id);

  Future<void> save(T item);
}
