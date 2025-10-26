import 'package:ba3_bs/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:dartz/dartz.dart';

import '../../../../../features/cheques/data/models/cheque_type.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';

class ChequeTypeRepository extends RemoteDataSourceRepository<ChequeType> {
  List<ChequeType>? _cache; // Internal cache

  ChequeTypeRepository(super.dataSource);

  /// Internal method to get all cheques with caching
  Future<Either<Failure, List<ChequeType>>> _getAllCached() async {
    if (_cache != null) {
      return Right(_cache!); // Return cached data
    }

    try {
      final result = await getAll();
      return result.fold(
            (failure) => Left(failure),
            (cheques) {
          _cache = cheques; // Cache the data
          return Right(cheques);
        },
      );
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }

  /// Lookup by label
  Future<Either<Failure, ChequeType>> byLabel(String label) async {
    final result = await _getAllCached();
    return result.fold(
          (failure) => Left(failure),
          (cheques) {
        try {
          final cheque = cheques.firstWhere((c) => c.label == label);
          return Right(cheque);
        } catch (e) {
          return Left(Failure(ResponseCode.NOT_FOUND, 'No ChequeType with label: $label'));
        }
      },
    );
  }

  /// Lookup by value
  Future<Either<Failure, ChequeType>> byValue(String value) async {
    final result = await _getAllCached();
    return result.fold(
          (failure) => Left(failure),
          (cheques) {
        try {
          final cheque = cheques.firstWhere((c) => c.value == value);
          return Right(cheque);
        } catch (e) {
          return Left(Failure(ResponseCode.NOT_FOUND, 'No ChequeType with value: $value'));
        }
      },
    );
  }

  /// Lookup by typeGuide
  Future<Either<Failure, ChequeType>> byTypeGuide(String typeGuide) async {
    final result = await _getAllCached();
    return result.fold(
          (failure) => Left(failure),
          (cheques) {
        try {
          final cheque = cheques.firstWhere((c) => c.typeGuide == typeGuide);
          return Right(cheque);
        } catch (e) {
          return Left(Failure(ResponseCode.NOT_FOUND, 'No ChequeType with typeGuide: $typeGuide'));
        }
      },
    );
  }

  /// Optional: Clear the cache (if data changes remotely)
  void clearCache() {
    _cache = null;
  }
}
