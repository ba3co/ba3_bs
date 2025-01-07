import 'dart:developer';

import 'package:ba3_bs/core/services/firebase/interfaces/listen_datasource.dart';
import 'package:dartz/dartz.dart';


import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import 'datasource_repo.dart';

class ListenRepository<T> extends DataSourceRepository<T> {
  final ListenableDatasource<T> _listenableDatasource;

  ListenRepository(this._listenableDatasource) : super(_listenableDatasource);

  Either<Failure, Stream<T>>listenDoc(String userId)  {
    try {
      final savedItems =  _listenableDatasource.listenToDocument(documentId: userId);
      return Right(savedItems); // Return the list of saved items
    } catch (e, stackTrace) {
      log('Error in saveAll: $e', stackTrace: stackTrace);
      return Left(ErrorHandler(e).failure); // Return error
    }
  }


}
