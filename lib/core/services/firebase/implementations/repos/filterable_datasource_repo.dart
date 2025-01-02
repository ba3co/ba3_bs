import 'dart:developer';

import 'package:ba3_bs/core/services/firebase/interfaces/filterable_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../models/date_filter.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'datasource_repo.dart';

class FilterableDataSourceRepository<T> extends DataSourceRepository<T> {
  final FilterableDatasource<T> _filterableDatasource;

  FilterableDataSourceRepository(this._filterableDatasource) : super(_filterableDatasource);

  Future<Either<Failure, List<T>>> fetchWhere<V>(
      {required String field, required V value, DateFilter? dateFilter}) async {
    try {
      final savedItems = await _filterableDatasource.fetchWhere(field: field, value: value, dateFilter: dateFilter);
      return Right(savedItems); // Return the list of saved items
    } catch (e) {
      log('Error in fetchWhere: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
