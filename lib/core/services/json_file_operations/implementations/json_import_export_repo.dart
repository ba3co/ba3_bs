import 'dart:developer';
import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../network/error/error_handler.dart';
import '../../../network/error/failure.dart';
import '../interfaces/export/i_json_export_repository.dart';
import '../interfaces/export/i_json_export_service.dart';
import '../interfaces/import/i_json_import_repository.dart';
import '../interfaces/import/i_json_import_service.dart';

class JsonImportExportRepository<T> implements IJsonImportRepository<T>, IJsonExportRepository<T> {
  final IJsonImportService<T> _jsonImport;
  final IJsonExportService<T> _jsonExport;

  JsonImportExportRepository(this._jsonImport, this._jsonExport);

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


  @override
  Future<Either<Failure, String>> exportJsonFile(List<T> itemsModels) async {
    try {
      String filePath = await _jsonExport.exportToFile(itemsModels);
      return Right(filePath);
    } catch (e) {
      log('[$e] فشل في تصدير الملف');
      return Left(ErrorHandler(e).failure);
    }
  }
}
