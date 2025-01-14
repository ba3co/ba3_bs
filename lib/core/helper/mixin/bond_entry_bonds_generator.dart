import 'package:ba3_bs/features/bond/data/models/bond_model.dart';
import 'package:ba3_bs/features/bond/service/bond/bond_entry_bond_service.dart';

import '../../../features/bond/data/models/entry_bond_model.dart';
import '../enums/enums.dart';

mixin BondEntryBondsGenerator on BondEntryBondService {
  List<EntryBondModel> generateEntryBonds(List<BondModel> bonds) => bonds
      .map(
        (bond) => createEntryBondModel(
          originType: EntryBondType.bond,
          bondModel: bond
        ),
      )
      .toList();
}
