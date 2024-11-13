import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:dartz/dartz.dart';

import '../../../network/error/failure.dart';
import '../abstract/i_json_export_service.dart';

class JsonExportRepository<T> {
  final IJsonExportService<T> _jsonExport;

  JsonExportRepository(this._jsonExport);

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
