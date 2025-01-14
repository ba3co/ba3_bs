import 'package:ba3_bs/core/helper/mixin/bond_entry_bonds_generator.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';

import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';

class AllBondsService extends BondEntryBondsGenerator {
  EntryBondController get entryBondController => read<EntryBondController>();

  generateEntryBondsFromAllBonds({required List<BondModel> bonds}) {
    final entryBonds = generateEntryBonds(bonds);

    for (final entryBond in entryBonds) {
      entryBondController.saveEntryBondModel(entryBondModel: entryBond);
    }
  }

}
