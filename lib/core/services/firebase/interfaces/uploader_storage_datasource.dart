import 'i_remote_storage_service.dart';
import 'remote_datasource_base.dart';

abstract class UploaderCapability<T> {
  Future<String> uploadImage(String imagePath);
}

abstract class UploaderStorageDataSource<T> extends RemoteDatasourceBase<T> implements UploaderCapability<T> {
  final IRemoteStorageService<String> databaseStorageService;

  UploaderStorageDataSource({required super.databaseService, required this.databaseStorageService});
}
