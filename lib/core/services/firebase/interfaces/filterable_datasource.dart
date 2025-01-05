import '../../../models/date_filter.dart';
import 'datasource_base.dart';

abstract class FetchWhereCapability<T> {
  Future<List<T>> fetchWhere<V>({required String field, required V value, DateFilter? dateFilter});
}

abstract class FilterableDatasource<T> extends DatasourceBase<T> implements FetchWhereCapability<T> {
  FilterableDatasource({required super.databaseService});
}
