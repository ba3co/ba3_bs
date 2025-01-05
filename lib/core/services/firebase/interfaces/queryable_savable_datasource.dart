import 'bulk_savable_datasource.dart';
import 'datasource_base.dart';
import 'filterable_datasource.dart';

abstract class QueryableSavableDatasource<T> extends DatasourceBase<T>
    implements FetchWhereCapability<T>, SaveAllCapability<T> {
  QueryableSavableDatasource({required super.databaseService});
}
