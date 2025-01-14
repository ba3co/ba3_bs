import 'package:ba3_bs/core/helper/mixin/cheques_entry_bonds_generator.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../bond/controllers/entry_bond/entry_bond_controller.dart';

class AllChequesService extends ChequesEntryBondsGenerator {
  EntryBondController get entryBondController => read<EntryBondController>();

  generateEntryBondsFromAllCheques({required List<ChequesModel> chequesList}) {
    final entryBonds = generateEntryBonds(chequesList);

    for (final entryBond in entryBonds) {
      entryBondController.saveEntryBondModel(entryBondModel: entryBond);
    }
  }
}
