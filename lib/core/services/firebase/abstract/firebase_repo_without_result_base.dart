import 'package:dartz/dartz.dart';

import '../../../network/error/failure.dart';
import 'i_firebase_repo.dart';

abstract class FirebaseRepositoryWithoutResultBase<T> implements IFirebaseRepository<T> {
  @override
  Future<Either<Failure, List<T>>> getAll();

  @override
  Future<Either<Failure, T>> getById(String id);

  @override
  Future<Either<Failure, Unit>> delete(String id);

  Future<Either<Failure, Unit>> save(T item);
}
