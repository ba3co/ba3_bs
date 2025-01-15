import 'package:ba3_bs/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../bond/data/models/entry_bond_model.dart';

mixin BondEntryBondService {
  EntryBondModel createEntryBondModel({
    required EntryBondType originType,
    required BondModel bondModel,
  }) =>
      EntryBondModel(
        origin: EntryBondOrigin(
          originId: bondModel.payGuid,
          originType: originType,
          originTypeId: bondModel.payTypeGuid,
        ),
        items: EntryBondItems(
          id: bondModel.payGuid!,
          itemList: generateBondItems(bondModel: bondModel),
        ),
      );

  List<EntryBondItemModel> generateBondItems({required BondModel bondModel}) {
    List<EntryBondItemModel> itemBonds = [];

    final date = _currentDate;
    final note = "سند قيد ل${BondType.byTypeGuide(bondModel.payTypeGuid!).value} رقم :${bondModel.payNumber}";
    final originId = bondModel.payGuid;
    for (var element in bondModel.payItems.itemList) {
      itemBonds.add(EntryBondItemModel(
        originId: originId,
        date: bondModel.payDate ?? date,
        note: note,
        account: AccountEntity(
          id:  element.entryAccountGuid!,
          name:element.entryAccountName!,
        ),
        bondItemType: element.entryCredit! > 0 ? BondItemType.creditor : BondItemType.debtor,
        amount: element.entryCredit! > 0 ? element.entryCredit : element.entryDebit,
      ));
    }
    return itemBonds;
  }

  String get _currentDate => DateTime.now().dayMonthYear;
}
