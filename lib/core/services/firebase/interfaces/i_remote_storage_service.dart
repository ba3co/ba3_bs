abstract class IRemoteStorageService<T> {
  /// When [storageFileName] is set, the object path is `path/storageFileName`.
  /// Otherwise a timestamped `.jpg` name is used under [path].
  Future<T> uploadImage({
    required String imagePath,
    required String path,
    String? storageFileName,
  });
}
