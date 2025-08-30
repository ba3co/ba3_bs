import '../../bond/data/models/entry_bond_model.dart';

class FilterEntryBondItemsByAmountUseCase {
  List<EntryBondItemModel> execute({
    double? minAmount,
    double? maxAmount,
    required List<EntryBondItemModel> entryBondItems,
  }) {
    return entryBondItems.where((item) {
      final double? amount = item.amount;
      if (amount == null) return false;

      if (minAmount != null && amount < minAmount) {
        return false;
      }

      if (maxAmount != null && amount > maxAmount) {
        return false;
      }

      return true;
    }).toList();
  }
}

