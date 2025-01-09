import 'package:ba3_bs/core/services/firebase/interfaces/remote_datasource_base.dart';

import 'bulk_savable_datasource.dart';

/// Abstract class for ListenCapability
abstract class ListenCapability<T> {
  /// Abstract method for listening to changes in a collection
  Stream<T> subscribeToDoc({required String documentId});
}

/// Implementation of ListenDatasource
abstract class ListenableDatasource<T> extends RemoteDatasourceBase<T>
    implements ListenCapability<T>, SaveAllCapability<T> {
  ListenableDatasource({required super.databaseService});
}
