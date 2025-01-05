import 'datasource_base.dart';

abstract class SaveAllCapability<T> {
  Future<List<T>> saveAll(List<T> items);
}

abstract class BulkSavableDatasource<T> extends DatasourceBase<T> implements SaveAllCapability<T> {
  BulkSavableDatasource({required super.databaseService});
}
