import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../network/error/failure.dart';

abstract class IJsonImportRepository<T> {
  Either<Failure, List<T>> importJsonFileJson(File filePath);
  Either<Failure, List<T>> importJsonFileXml(File filePath);
}
