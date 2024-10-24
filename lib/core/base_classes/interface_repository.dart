import 'package:dartz/dartz.dart';

import '../network/error/failure.dart';

abstract class IRepository<T> {
  Future<Either<Failure, List<T>>> getAll();

  Future<Either<Failure, T?>> getById(String id);

  Future<Either<Failure, Unit>> save(T item);

  Future<Either<Failure, Unit>> delete(String id);
}
