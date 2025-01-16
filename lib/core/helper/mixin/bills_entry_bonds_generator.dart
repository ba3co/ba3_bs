import '../../../features/bill/data/models/bill_model.dart';
import '../../../features/bond/data/models/entry_bond_model.dart';
import '../../services/entry_bond_creator/implementations/entry_bond_creator_factory.dart';
import '../../services/entry_bond_creator/interfaces/entry_bonds_generator.dart';
import '../enums/enums.dart';

class BillsEntryBondsGenerator implements EntryBondsGenerator<BillModel> {
  @override
  List<EntryBondModel> generateEntryBonds(List<BillModel> bills) {
    return bills.map((bill) {
      final creator = EntryBondCreatorFactory.getService(bill);

      return creator.createEntryBond(
        originType: EntryBondType.bill,
        model: bill,
        isSimulatedVat: false,
      );
    }).toList();
  }
}
