import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:ba3_bs/core/network/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../datasources/base_datasource.dart';
import 'base_repo.dart';

class BaseRepositoryImpl<T> implements BaseRepository<T> {
  final BaseDatasource _dataSource;
  final T Function(Map) fromJson;

  BaseRepositoryImpl(this._dataSource, this.fromJson);

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(unit); // Return success
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, List<T>>> getAll() async {
    try {
      final rawItems = await _dataSource.fetchAll();
      final items = rawItems.map((doc) => fromJson(doc.data() as Map)).toList();
      return Right(items); // Return list of items
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, T>> getById(String id) async {
    try {
      final rawItem = await _dataSource.fetchById(id);
      final item = fromJson(rawItem.data() as Map);
      return Right(item); // Return the found item
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  @override
  Future<Either<Failure, Unit>> save(T item) async {
    try {
      await _dataSource.save(item);
      return const Right(unit); // Return success
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
