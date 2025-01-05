import '../../../models/date_filter.dart';
import '../../../models/query_filter.dart';
import 'datasource_base.dart';

abstract class FetchWhereCapability<T> {
  Future<List<T>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter});
}

abstract class FilterableDatasource<T> extends DatasourceBase<T> implements FetchWhereCapability<T> {
  FilterableDatasource({required super.databaseService});
}
