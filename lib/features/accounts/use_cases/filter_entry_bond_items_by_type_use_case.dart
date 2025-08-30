import '../../bond/data/models/entry_bond_model.dart';
import '../../../../core/helper/enums/enums.dart';


class FilterEntryBondItemsByTypeUseCase {

  List<EntryBondItemModel> execute(
      BondItemType bondItemType,
      List<EntryBondItemModel> entryBondItems,
      ) {
    return entryBondItems.where((item) {
      return item.bondItemType == bondItemType;
    }).toList();
  }
}
