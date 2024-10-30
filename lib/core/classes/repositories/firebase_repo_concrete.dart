import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:ba3_bs/core/network/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../datasources/firebase_datasource_base.dart';
import 'firebase_repo_base.dart';

class FirebaseRepositoryConcrete<T> implements FirebaseRepositoryBase<T> {
  final FirebaseDatasourceBase<T> _dataSource;

  FirebaseRepositoryConcrete(this._dataSource);

  @override
  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final items = await _dataSource.fetchAll();
      return Right(items); // Return list of items
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, T>> getById(String id) async {
    try {
      final item = await _dataSource.fetchById(id);
      return Right(item); // Return the found item
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(unit); // Return success
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, Unit>> save(T item) async {
    try {
      await _dataSource.save(item);
      return const Right(unit); // Return success
    } catch (e) {
      log('Error in save: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
