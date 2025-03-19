import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../models/date_filter.dart';
import '../../../../models/query_filter.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../interfaces/uploader_able_datasource.dart';
import 'remote_datasource_repo.dart';

class UploaderAbleDatasourceRepository<T> extends RemoteDataSourceRepository<T> {
  final UploaderAbleDatasource<T> _uploaderAbleDatasource;

  UploaderAbleDatasourceRepository(this._uploaderAbleDatasource) : super(_uploaderAbleDatasource);

  Future<Either<Failure, String>> uploadImage({required String imagePath}) async {
    try {
      final savedItems = await _uploaderAbleDatasource.uploadImage(imagePath: imagePath);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in uploadImage: $e', stackTrace: stackTrace, name: 'UploaderAbleDatasourceRepo uploadImage');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
  Future<Either<Failure, List<T>>> fetchWhere({required List<QueryFilter> queryFilters, DateFilter? dateFilter}) async {
    try {
      final savedItems = await _uploaderAbleDatasource.fetchWhere(queryFilters: queryFilters);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in fetchWhere: $e', stackTrace: stackTrace, name: 'FilterableDataSourceRepository fetchWhere');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

}