import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../bond/data/models/entry_bond_model.dart';

mixin ChequesBondService {
  EntryBondModel createEntryBondModel({
    required EntryBondType originType,
    required ChequesModel chequesModel,
  }) {
    return EntryBondModel(
      origin: EntryBondOrigin(
        originId: chequesModel.chequesGuid,
        originType: originType,
        originTypeId: chequesModel.chequesTypeGuid,
      ),
      items: generateBondItems(
        chequesModel: chequesModel,
      ),
    );
  }

  List<EntryBondItemModel> generateBondItems({
    required ChequesModel chequesModel,
  }) {
    List<EntryBondItemModel> itemBonds = [];
    final date = _currentDate;
    final note = "سند قيد ل${ChequesType.byTypeGuide(chequesModel.chequesTypeGuid!).value} رقم :${chequesModel.chequesNumber}";
    final amount = chequesModel.chequesVal;
    final originId = chequesModel.chequesGuid;

    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.creditor,
      accountId: chequesModel.chequesAccount2Guid,
      accountName: chequesModel.chequesAccount2Name,
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      accountId: chequesModel.accPtr,
      accountName: chequesModel.accPtrName,
      date: date,
      originId: originId,
    ));
    if(chequesModel.isPayed!){
      itemBonds.add(EntryBondItemModel(
        note: note,
        amount: amount,
        bondItemType: BondItemType.debtor,
        accountId: chequesModel.chequesAccount2Guid,
        accountName: chequesModel.chequesAccount2Name,
        date: date,
        originId: originId,
      ));
      itemBonds.add(EntryBondItemModel(
        note: note,
        amount: amount,
        bondItemType: BondItemType.creditor,
        accountId: AppStrings.bankAccountId,
        accountName: AppStrings.bankToAccountName,
        date: date,
        originId: originId,
      ));
    }

    return itemBonds;
  }

  String get _currentDate => DateTime.now().toString().split(" ")[0];
}
