import '../../../../features/bond/data/models/entry_bond_model.dart';

abstract class EntryBondsGenerator<T> {
  List<EntryBondModel> generateEntryBonds(List<T> items);
}
