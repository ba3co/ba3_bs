import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/helper/mixin/bills_entry_bonds_generator.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../data/models/bill_model.dart';

class AllBillsService extends BillsEntryBondsGenerator {
  EntryBondController get entryBondController => read<EntryBondController>();

  generateEntryBondsFromAllBills({required List<BillModel> bills}) {
    final entryBonds = generateEntryBonds(bills);

    for (final entryBond in entryBonds) {
      entryBondController.saveEntryBondModel(entryBondModel: entryBond);
    }
  }
}
