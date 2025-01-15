import 'package:ba3_bs/features/bond/data/models/bond_model.dart';

import '../../../features/bond/data/models/entry_bond_model.dart';
import '../../services/entry_bond_creator/implementations/entry_bond_creator_factory.dart';
import '../../services/entry_bond_creator/interfaces/entry_bonds_generator.dart';
import '../enums/enums.dart';

class BondEntryBondsGenerator implements EntryBondsGenerator<BondModel> {
  @override
  List<EntryBondModel> generateEntryBonds(List<BondModel> bonds) {
    return bonds.map((bond) {
      final creator = EntryBondCreatorFactory.getService(bond);

      return creator.createEntryBond(
        originType: EntryBondType.bond,
        model: bond,
      );
    }).toList();
  }
}
