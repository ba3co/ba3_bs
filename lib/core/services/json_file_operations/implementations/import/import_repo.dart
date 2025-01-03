import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';
import '../../interfaces/import/i_import_repository.dart';
import '../../interfaces/import/i_import_service.dart';

class ImportRepository<T> implements IImportRepository<T> {
  final IImportService<T> _jsonImport;

  ImportRepository(this._jsonImport);

  @override
  Either<Failure, List<T>> importJsonFileJson(File filePath) {
    try {
      List<T> itemsModels = _jsonImport.importFromFile(filePath);
      return Right(itemsModels);
    } catch (e) {
      log('[$e] فشل في استيراد الملف');
      return Left(ErrorHandler(e).failure);
    }
  }

  @override
  Either<Failure, List<T>> importJsonFileXml(File filePath) {
    try {
      List<T> itemsModels = _jsonImport.importFromXmlFile(filePath);
      return Right(itemsModels);
    } catch (e) {
      log('[$e] فشل في استيراد الملف');
      return Left(ErrorHandler(e).failure);
    }
  }
}
