import 'package:ba3_bs/core/services/firebase/implementations/repos/remote_datasource_repo.dart';
import 'package:dartz/dartz.dart';

import '../../../../../features/bond/data/models/bond_type.dart';
import '../../../../network/error/error_handler.dart';
import '../../../../network/error/failure.dart';

class BondTypeRepository extends RemoteDataSourceRepository<BondTypeModel> {
  List<BondTypeModel>? _cache; // Internal cache


  List<BondTypeModel>? get cachedBondTypes => _cache;

  BondTypeRepository(super.dataSource);

  /// Internal method to get all bond types with caching
  Future<Either<Failure, List<BondTypeModel>>> getAllCached() async {
    if (_cache != null) {
      return Right(_cache!); // Return cached data
    }

    try {
      final result = await getAll();
      return result.fold(
            (failure) => Left(failure),
            (bondTypes) {
          _cache = bondTypes; // Cache the data
          return Right(bondTypes);
        },
      );
    } catch (e) {
      return Left(ErrorHandler(e).failure); // Wrap in your Failure system
    }
  }


  /// Force refresh bond types from remote and update the cache
  Future<Either<Failure, List<BondTypeModel>>> refresh() async {
    try {
      final result = await getAll(); // Always fetch fresh from remote
      return result.fold(
            (failure) => Left(failure),
            (bondTypes) {
          _cache = bondTypes; // Update internal cache
          return Right(bondTypes);
        },
      );
    } catch (e) {
      return Left(ErrorHandler(e).failure);
    }
  }


  /// Lookup by label
  Future<Either<Failure, BondTypeModel>> byLabel(String label) async {
    final result = await getAllCached();
    return result.fold(
          (failure) => Left(failure),
          (bondTypes) {
        try {
          final bond = bondTypes.firstWhere((bond) => bond.label == label);
          return Right(bond);
        } catch (e) {
          return Left(Failure(ResponseCode.NOT_FOUND, 'No BondType with label: $label'));
        }
      },
    );
  }


  /// Lookup by value
  Future<Either<Failure, BondTypeModel>> byValue(String value) async {
    final result = await getAllCached();
    return result.fold(
          (failure) => Left(failure),
          (bondTypes) {
        try {
          final bond = bondTypes.firstWhere((bond) => bond.value == value);
          return Right(bond);
        } catch (e) {
          return Left(Failure(ResponseCode.NOT_FOUND, 'No BondType with value: $value'));
        }
      },
    );
  }

  /// Lookup by typeGuide
  Future<Either<Failure, BondTypeModel>> byTypeGuide(String typeGuide) async {
    final result = await getAllCached();
    return result.fold(
          (failure) => Left(failure),
          (bondTypes) {
        try {
          final bond = bondTypes.firstWhere((bond) => bond.typeGuide == typeGuide);
          return Right(bond);
        } catch (e) {
          return Left(Failure(ResponseCode.NOT_FOUND, 'No BondType with typeGuide: $typeGuide'));
        }
      },
    );
  }

  /// Optional: Clear the cache (if data changes remotely)
  void clearCache() {
    _cache = null;
  }
}

