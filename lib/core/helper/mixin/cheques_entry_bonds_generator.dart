import '../../../features/bond/data/models/entry_bond_model.dart';
import '../../../features/cheques/data/models/cheques_model.dart';
import '../../services/entry_bond_creator/implementations/entry_bond_creator_factory.dart';
import '../../services/entry_bond_creator/interfaces/entry_bonds_generator.dart';
import '../enums/enums.dart';

class ChequesEntryBondsGenerator implements EntryBondsGenerator<ChequesModel> {
  @override
  List<EntryBondModel> generateEntryBonds(List<ChequesModel> chequesList) {
    return chequesList.map((cheque) {
      final creator = EntryBondCreatorFactory.getService(cheque);

      return creator.createEntryBond(
        originType: EntryBondType.cheque,
        model: cheque,
      );
    }).toList();
  }
}
