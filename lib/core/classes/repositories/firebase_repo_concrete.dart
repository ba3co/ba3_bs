import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:ba3_bs/core/network/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../../bindings/model_deserialization_registry.dart';
import '../datasources/firebase_datasource_base.dart';
import 'firebase_repo_base.dart';

class FirebaseRepositoryConcrete<T> implements FirebaseRepositoryBase<T> {
  final FirebaseDatasourceBase _dataSource;

  FirebaseRepositoryConcrete(this._dataSource);

  // Retrieves the registered fromJson factory function for the specific model
  T Function(Map<String, dynamic>) get fromJson => getIt<T Function(Map<String, dynamic>)>();

  Map<String, dynamic> Function(T) get toJson => getIt<Map<String, dynamic> Function(T)>();

  @override
  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final rawItems = await _dataSource.fetchAll();
      final items = rawItems.map((doc) => fromJson(doc.data() as Map<String, dynamic>)).toList();
      return Right(items); // Return list of items
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, T>> getById(String id) async {
    try {
      final rawItem = await _dataSource.fetchById(id);
      final item = fromJson(rawItem.data() as Map<String, dynamic>);
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
      final itemData = toJson(item);
      await _dataSource.save(itemData); // Pass `toJson(item)` to save method
      return const Right(unit); // Return success
    } catch (e) {
      log('Error in save: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
