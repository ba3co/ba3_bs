import '../../bond/data/models/entry_bond_model.dart';


class FilterEntryBondItemsByBillTypesUseCase {
  List<EntryBondItemModel> execute(
      List<String> billTypes,
      List<EntryBondItemModel> entryBondItems,
      ) {
    if (billTypes.isEmpty) return entryBondItems;

    return entryBondItems.where((item) {
      final note = (item.note ?? "").toLowerCase();

      // Check if ANY billType is a substring of note
      return billTypes.any(
            (billType) => note.contains(billType.toLowerCase()),
      );
    }).toList();
  }
}

