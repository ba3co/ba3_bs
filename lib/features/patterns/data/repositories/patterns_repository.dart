import 'dart:developer';

import 'package:ba3_bs/core/network/error/error_handler.dart';
import 'package:ba3_bs/core/network/error/failure.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/base_classes/interface_data_source.dart';
import '../../../../core/base_classes/interface_repository.dart';
import '../models/bill_type_model.dart';

class PatternsRepository implements IRepository<BillTypeModel> {
  final IDataSource _dataSource;

  PatternsRepository(this._dataSource);

  @override
  Future<Either<Failure, Unit>> delete(String id) async {
    try {
      await _dataSource.delete(id);
      return const Right(unit); // Return success
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, List<BillTypeModel>>> getAll() async {
    try {
      final rawBillTypes = await _dataSource.fetchAll();
      final billTypes = rawBillTypes.map((doc) => BillTypeModel.fromJson(doc.data() as Map)).toList();
      return Right(billTypes); // Return list of bill types
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Return error
    }
  }

  @override
  Future<Either<Failure, BillTypeModel>> getById(String id) async {
    try {
      final rawBillType = await _dataSource.fetchById(id);
      final billType = BillTypeModel.fromJson(rawBillType.data()!);
      return Right(billType); // Return the found bill type
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Handle the error and return Failure
    }
  }

  @override
  Future<Either<Failure, Unit>> save(BillTypeModel item) async {
    try {
      await _dataSource.save(item);
      return const Right(unit); // Return success
    } catch (e) {
      log('e $e');
      return Left(ErrorHandler(e).failure); // Return error
    }
  }
}
