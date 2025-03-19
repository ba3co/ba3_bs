import '../../../models/date_filter.dart';
import '../../../models/query_filter.dart';
import 'remote_datasource_base.dart';

abstract class UploaderCapability<T> {
  Future<String> uploadImage({required String imagePath});
  Future<List<T>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter});

}

abstract class UploaderAbleDatasource<T> extends RemoteDatasourceBase<T> implements UploaderCapability<T> {
  UploaderAbleDatasource({required super.databaseService});
}