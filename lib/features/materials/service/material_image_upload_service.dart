import 'package:ba3_bs/core/services/firebase/interfaces/i_remote_storage_service.dart';

/// Uploads images to Firebase Storage via [IRemoteStorageService].
class MaterialImageUploadService {
  MaterialImageUploadService(this._remoteStorageService);

  final IRemoteStorageService<String> _remoteStorageService;

  /// Generic upload; [storagePath] is the folder prefix under the default bucket.
  Future<String> uploadImage({
    required String imagePath,
    required String storagePath,
    String? storageFileName,
  }) =>
      _remoteStorageService.uploadImage(
        imagePath: imagePath,
        path: storagePath,
        storageFileName: storageFileName,
      );

  /// Material image: `materials/{materialId}.jpg` in Firebase Storage.
  Future<String> uploadMaterialImage({
    required String imagePath,
    required String materialId,
  }) =>
      _remoteStorageService.uploadImage(
        imagePath: imagePath,
        path: 'materials',
        storageFileName: '$materialId.jpg',
      );
}
