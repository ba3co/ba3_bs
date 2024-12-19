import 'datasource_base.dart';

abstract class DatasourceBaseWithSaveAll<T> extends DatasourceBase<T> {
  DatasourceBaseWithSaveAll({required super.databaseService});

  Future<List<T>> saveAll(List<T> items);
}