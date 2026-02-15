import 'package:flutter/material.dart';

import '../../bond/data/models/entry_bond_model.dart';


class FilterEntryBondItemsByBillTypesUseCase {
  List<EntryBondItemModel> execute(
      List<String> billTypesIds,
      List<EntryBondItemModel> entryBondItems,
      ) {
    if (billTypesIds.isEmpty) return entryBondItems;

    debugPrint("FilterEntryBondItemsByBillTypesUseCase the billtype ids are $billTypesIds");

    return entryBondItems.where((item) {
      final billTypeId = (item.originTypeId ?? "").toLowerCase();
      //item.printDetails();


      // Check if ANY billType is a substring of note
      return billTypesIds.any(
            (billType) => billTypeId==billType.toLowerCase()
      );
    }).toList();
  }
}

