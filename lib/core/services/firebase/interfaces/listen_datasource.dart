import 'package:ba3_bs/core/services/firebase/interfaces/datasource_base.dart';

/// Abstract class for ListenCapability
abstract class ListenCapability<T> {
  /// Abstract method for listening to changes in a collection
  Stream<T> listenToDocument({
    required String documentId
  });
}
/// Implementation of ListenDatasource
abstract class ListenableDatasource<T> extends DatasourceBase<T> implements ListenCapability<T>{
  ListenableDatasource({required super.databaseService});




}

