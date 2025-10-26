import 'package:dartz/dartz.dart';
import 'package:ba3_bs/core/network/error/failure.dart';
import 'package:ba3_bs/features/bond/data/models/bond_type.dart';
import 'package:ba3_bs/core/services/firebase/implementations/repos/bond_type_repository.dart';

class GetBondTypeByGuideUseCase {
  final BondTypeRepository bondTypeRepository;

  GetBondTypeByGuideUseCase(this.bondTypeRepository);

  Future<Either<Failure, BondTypeModel>> call(String typeGuide) {
    return bondTypeRepository.byTypeGuide(typeGuide);
  }
}
