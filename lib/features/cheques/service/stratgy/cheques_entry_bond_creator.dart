import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/date_time_extensions.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/services/entry_bond_creator/implementations/base_entry_bond_creator.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/data/models/entry_bond_model.dart';

class ChequesStrategyFactory {
  static final ChequesBondStrategy _chequesStrategy = ChequesBondStrategy();
  static final PayBondStrategy _payStrategy = PayBondStrategy();
  static final RefundBondStrategy _refundStrategy = RefundBondStrategy();

  static List<BaseEntryBondCreator<ChequesModel>> _getStrategy(ChequesBondStrategyType type) {
    switch (type) {
      case ChequesBondStrategyType.chequesStrategy:
        return [_chequesStrategy];
      case ChequesBondStrategyType.payStrategy:
        return [_payStrategy];
      case ChequesBondStrategyType.refundStrategy:
        return [_refundStrategy];
      case ChequesBondStrategyType.payChequesStrategy:
        return [_chequesStrategy, _payStrategy];
      case ChequesBondStrategyType.refundChequesStrategy:
        return [_chequesStrategy, _refundStrategy];
    }
  }

  /// Determines the appropriate strategies based on the ChequesModel.
  static List<BaseEntryBondCreator<ChequesModel>> determineStrategy(ChequesModel chequesModel,
      {ChequesBondStrategyType? type}) {
    if (type != null) {
      return _getStrategy(type);
    }

    if (chequesModel.isPayed == true) {
      return _getStrategy(ChequesBondStrategyType.payChequesStrategy);
    } else if (chequesModel.isRefund == true) {
      return _getStrategy(ChequesBondStrategyType.refundChequesStrategy);
    } else {
      return _getStrategy(ChequesBondStrategyType.chequesStrategy);
    }
  }
}

abstract class BaseChequesBondStrategy extends BaseEntryBondCreator<ChequesModel> {
  /// Helper method to create bond items with common logic.
  List<EntryBondItemModel> createBondItems({
    required String note,
    required String originId,
    required double amount,
    required String date,
    required AccountEntity creditAccount,
    required AccountEntity debitAccount,
  }) {
    return [
      EntryBondItemModel(
        note: note,
        amount: amount,
        bondItemType: BondItemType.creditor,
        account: creditAccount,
        date: date,
        originId: originId,
      ),
      EntryBondItemModel(
        note: note,
        amount: amount,
        bondItemType: BondItemType.debtor,
        account: debitAccount,
        date: date,
        originId: originId,
      ),
    ];
  }
}

class ChequesBondStrategy extends BaseChequesBondStrategy {
  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) {
    final date = model.chequesDate ?? DateTime.now().dayMonthYear;
    final note = "سند قيد ل${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}";
    final amount = model.chequesVal!;
    final originId = model.chequesGuid!;
    return createBondItems(
      note: note,
      originId: originId,
      amount: amount,
      date: date,
      creditAccount: AccountEntity(id: model.chequesAccount2Guid!, name: model.chequesAccount2Name!),
      debitAccount: AccountEntity(id: model.accPtr!, name: model.accPtrName!),
    );
  }

  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
        originId: model.chequesGuid!,
        originType: originType,
        originTypeId: model.chequesTypeGuid,
      );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;
}

class PayBondStrategy extends BaseChequesBondStrategy {
  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) {
    final date = model.chequesDate ?? DateTime.now().dayMonthYear;
    final note = "سند قيد لدفع${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}";
    final amount = model.chequesVal!;
    final originId = model.chequesGuid!;
    return createBondItems(
      note: note,
      originId: originId,
      amount: amount,
      date: date,
      creditAccount: AccountEntity(id: AppStrings.bankAccountId, name: AppStrings.bankToAccountName),
      debitAccount: AccountEntity(id: model.chequesAccount2Guid!, name: model.chequesAccount2Name!),
    );
  }

  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
        originId: model.chequesGuid!,
        originType: originType,
        originTypeId: model.chequesTypeGuid,
      );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;
}

class RefundBondStrategy extends BaseChequesBondStrategy {
  @override
  List<EntryBondItemModel> generateItems({required ChequesModel model, bool? isSimulatedVat}) {
    final date = model.chequesDate ?? DateTime.now().dayMonthYear;
    final note = "سند قيد لارجاع ${ChequesType.byTypeGuide(model.chequesTypeGuid!).value} رقم :${model.chequesNumber}";
    final amount = model.chequesVal!;
    final originId = model.chequesGuid!;
    return createBondItems(
      note: note,
      originId: originId,
      amount: amount,
      date: date,
      creditAccount: AccountEntity(id: model.accPtr!, name: model.accPtrName!),
      debitAccount: AccountEntity(id: model.chequesAccount2Guid!, name: model.chequesAccount2Name!),
    );
  }

  @override
  EntryBondOrigin createOrigin({required ChequesModel model, required EntryBondType originType}) => EntryBondOrigin(
        originId: model.chequesGuid!,
        originType: originType,
        originTypeId: model.chequesTypeGuid,
      );

  @override
  String getModelId(ChequesModel model) => model.chequesGuid!;
}
