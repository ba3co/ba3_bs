import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/entry_bond_creator/implementations/base_entry_bond_creator.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/data/models/entry_bond_model.dart';

class OldChequesEntryBondCreator {
  final ChequesBondStrategy _chequesStrategy = ChequesBondStrategy();
  final PayChequesBondStrategy _payChequesStrategy = PayChequesBondStrategy();
  final RefundPayChequesBondStrategy _refundPayChequesStrategy = RefundPayChequesBondStrategy();

  /// Determines the appropriate strategy based on the ChequesModel.
  BaseEntryBondCreator<ChequesModel> determineStrategy({required ChequesModel chequesModel, bool? isPayStrategy}) {
    if (isPayStrategy != null) {
      if (isPayStrategy) {
        return _payChequesStrategy;
      } else {
        return _refundPayChequesStrategy;
      }
    } else {
      if (chequesModel.isPayed == false&&chequesModel.isRefund == false) {
        return _chequesStrategy;
      } else  if (chequesModel.isPayed == true) {
        return _payChequesStrategy;
        return _chequesStrategy;
      }else{
        return _payChequesStrategy;
        return _refundPayChequesStrategy;
      }
    }
  }
}

class ChequesBondStrategy extends BaseEntryBondCreator<ChequesModel> {
  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) {
    List<EntryBondItemModel> itemBonds = [];
    final date = model.chequesDate ?? DateTime.now().dayMonthYear;
    final note = "سند قيد ل${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}";
    final amount = model.chequesVal;
    final originId = model.chequesGuid;
    itemBonds.addAll(
        _generateNormalEntryBond(chequesModel: model, note: note, originId: originId!, amount: amount!, date: date));



    return itemBonds;
  }

  List<EntryBondItemModel> _generateNormalEntryBond(
      {required ChequesModel chequesModel,
        required String note,
        required String originId,
        required double amount,
        required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      account: AccountEntity(
        id: chequesModel.chequesAccount2Guid!,
        name: chequesModel.chequesAccount2Name!,
      ),
      bondItemType: BondItemType.creditor,
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      account: AccountEntity(
        id: chequesModel.accPtr!,
        name: chequesModel.accPtrName!,
      ),
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }

  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
    originId: model.chequesGuid,
    originType: originType,
    originTypeId: model.chequesTypeGuid,
  );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;
}

class PayChequesBondStrategy extends BaseEntryBondCreator<ChequesModel> {
  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
    originId: model.chequesGuid,
    originType: originType,
    originTypeId: model.chequesTypeGuid,
  );

  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) =>
      _generatePayEntryBond(
        chequesModel: model,
        note: "سند قيد لدفع${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}",
        amount: model.chequesVal!,
        date: model.chequesDate ?? DateTime.now().dayMonthYear,
        originId: model.chequesGuid!,
      );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;
  List<EntryBondItemModel> _generatePayEntryBond(
      {required ChequesModel chequesModel,
        required String note,
        required String originId,
        required double amount,
        required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.debtor,
      account: AccountEntity(
        id: chequesModel.chequesAccount2Guid!,
        name: chequesModel.chequesAccount2Name!,
      ),
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.creditor,
      account: AccountEntity(
        id: AppStrings.bankAccountId,
        name: AppStrings.bankToAccountName,
      ),
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }

}

class RefundPayChequesBondStrategy extends BaseEntryBondCreator<ChequesModel> {
  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
    originId: model.chequesGuid,
    originType: originType,
    originTypeId: model.chequesTypeGuid,
  );

  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) => _generateRefundPayEntryBond(
    chequesModel: model,
    note: "سند قيد لارجاع ${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}",
    amount: model.chequesVal!,
    date: model.chequesDate ?? DateTime.now().dayMonthYear,
    originId: model.chequesGuid!,
  );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;



  List<EntryBondItemModel> _generateRefundPayEntryBond(
      {required ChequesModel chequesModel,
        required String note,
        required String originId,
        required double amount,
        required String date}) {
    List<EntryBondItemModel> itemBonds = [];
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      account: AccountEntity(
        id: chequesModel.chequesAccount2Guid!,
        name: chequesModel.chequesAccount2Name!,
      ),
      bondItemType: BondItemType.debtor,
      date: date,
      originId: originId,
    ));
    itemBonds.add(EntryBondItemModel(
      note: note,
      amount: amount,
      bondItemType: BondItemType.creditor,
      account: AccountEntity(
        id: chequesModel.accPtr!,
        name: chequesModel.accPtrName!,
      ),
      date: date,
      originId: originId,
    ));
    return itemBonds;
  }
}