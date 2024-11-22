import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:ba3_bs/core/network/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../interfaces/firebase_datasource_with_result_base.dart';

class FirebaseRepositoryWithResultImpl<T> {
  final FirebaseDatasourceWithResultBase<T> _dataSource;

  FirebaseRepositoryWithResultImpl(this._dataSource);

  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final items = await _dataSource.fetchAll();
      return Right(items); // Return list of items
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> getById(String id) async {
    try {
      final item = await _dataSource.fetchById(id);
      return Right(item); // Return the found item
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(unit); // Return success
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> save(T item) async {
    try {
      final savedItem = await _dataSource.save(item);
      return Right(savedItem); // Return success
    } catch (e) {
      log('Error in save: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
