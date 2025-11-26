import 'package:ba3_bs/features/bond/data/models/bond_type.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/bond_type_repository.dart';
import 'package:dartz/dartz.dart';

import '../../../core/network/error/failure.dart';

class GetAllBondTypesUseCase {
  final BondTypeRepository _repository;

  GetAllBondTypesUseCase(this._repository);

  /// Returns a list of bond types or a failure
  Future<Either<Failure, List<BondTypeModel>>> call({bool forceRefresh = false}) async {
    return await _repository.getAllCached();
  }
}
