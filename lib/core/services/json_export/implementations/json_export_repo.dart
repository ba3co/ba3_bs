import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:dartz/dartz.dart';

import '../../../network/error/failure.dart';
import '../abstract/i_json_export_service.dart';

class JsonExportRepository<T> {
  final IJsonExportService<T> _jsonExport;

  JsonExportRepository(this._jsonExport);

  Future<Either<Failure, Unit>> exportJsonFile(List<T> itemsModels) async {
    try {
      await _jsonExport.exportToFile(itemsModels);
      return const Right(unit);
    } catch (e) {
      log('Error exporting bills: $e');
      return Left(Failure(ResponseCode.UNKNOWN, 'Failed to export bill data: $e'));
    }
  }
}
