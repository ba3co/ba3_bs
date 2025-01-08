import 'dart:developer';

import 'package:ba3_bs/core/services/firebase/interfaces/filterable_datasource.dart';
import 'package:dartz/dartz.dart';

import '../../../../models/date_filter.dart';
import '../../../../models/query_filter.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'remote_datasource_repo.dart';

class FilterableDataSourceRepository<T> extends DataSourceRepository<T> {
  final FilterableDatasource<T> _filterableDatasource;

  FilterableDataSourceRepository(this._filterableDatasource) : super(_filterableDatasource);

  Future<Either<Failure, List<T>>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    try {
      final savedItems = await _filterableDatasource.fetchWhere(queryFilters: queryFilters);
      return Right(savedItems); // Return the list of saved items
    } catch (e) {
      log('Error in fetchWhere: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
