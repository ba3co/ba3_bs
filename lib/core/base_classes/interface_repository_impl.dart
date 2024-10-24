import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:ba3_bs/core/network/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/base_classes/interface_data_source.dart';
import '../../../../core/base_classes/interface_repository.dart';
import 'base_model.dart';

class InterfaceRepositoryImpl<T extends BaseModel> implements IRepository<T> {
  final IDataSource _dataSource;
  final T Function(Map) fromJsonFactory;

  InterfaceRepositoryImpl(this._dataSource, this.fromJsonFactory);

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
      final items = rawItems.map((doc) => fromJsonFactory(doc.data() as Map)).toList();
      return Right(items); // Return list of items
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, T>> getById(String id) async {
    try {
      final rawItem = await _dataSource.fetchById(id);
      final item = fromJsonFactory(rawItem.data() as Map);
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
