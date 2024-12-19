import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../network/error/error_handler.dart';
import '../../../network/error/failure.dart';
import '../interfaces/datasource_base_with_save_all.dart';
import 'datasource_repo.dart';

class DataSourceRepositoryWithSaveAll<T> extends DataSourceRepository<T> {
  final DatasourceBaseWithSaveAll<T> datasourceBaseWithSaveAll;

  DataSourceRepositoryWithSaveAll({required this.datasourceBaseWithSaveAll}) : super(datasourceBaseWithSaveAll);

  Future<Either<Failure, List<T>>> saveAll(List<T> items) async {
    try {
      final savedItems = await datasourceBaseWithSaveAll.saveAll(items);
      return Right(savedItems); // Return the list of saved items
    } catch (e) {
      log('Error in saveAll: $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}