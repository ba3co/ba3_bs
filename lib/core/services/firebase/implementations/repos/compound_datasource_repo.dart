import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../models/count_query_filter.dart';
import '../../../../models/date_filter.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../interfaces/compound_datasource_base.dart';

class CompoundDatasourceRepository<T, ItemTypeModel> {
  final CompoundDatasourceBase<T, ItemTypeModel> _dataSource;

  CompoundDatasourceRepository(this._dataSource);

  Future<Either<Failure, List<T>>> getAll(ItemTypeModel itemTypeModel) async {
    try {
      final items = await _dataSource.fetchAll(itemTypeModel: itemTypeModel);
      return Right(items); // Return list of items
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, List<T>>> fetchWhere<V>(
      {required ItemTypeModel itemTypeModel, required String field, required V value, DateFilter? dateFilter}) async {
    try {
      final savedItems = await _dataSource.fetchWhere(
          itemTypeModel: itemTypeModel, field: field, value: value, dateFilter: dateFilter);
      return Right(savedItems); // Return the list of saved items
    } catch (e) {
      log('Error in fetchWhere: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> getById({required String id, required ItemTypeModel itemTypeModel}) async {
    try {
      final item = await _dataSource.fetchById(id: id, itemTypeModel: itemTypeModel);
      return Right(item); // Return the found item
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  Future<Either<Failure, Unit>> delete(T item) async {
    try {
      await _dataSource.delete(item: item);
      return const Right(unit); // Return success
    } catch (e) {
      log('Error: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, T>> save(T item, {bool? save}) async {
    try {
      final savedItem = await _dataSource.save(item: item, save: save);
      return Right(savedItem); // Return success
    } catch (e) {
      log('Error in save: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, int>> count({required ItemTypeModel itemTypeModel, CountQueryFilter? countQueryFilter}) async {
    try {
      final count = await _dataSource.countDocuments(itemTypeModel: itemTypeModel, countQueryFilter: countQueryFilter);
      return Right(count); // Return the found item
    } catch (e) {
      log('Error in count: $e');
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  Future<Either<Failure, List<T>>> saveAll(List<T> items) async {
    try {
      final savedItems = await _dataSource.saveAll(items);
      return Right(savedItems); // Return the list of saved items
    } catch (e) {
      log('Error in fetchWhere: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  Future<Either<Failure, Map<ItemTypeModel, List<T>>>> fetchAllNested(List<ItemTypeModel> itemTypes) async {
    try {
      final nestedItems = await _dataSource.fetchAllNested(itemTypes: itemTypes);
      return Right(nestedItems); // Return list of  Nested items
    } catch (e) {
      log('Error in fetchAllNested: $e');
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }
}
