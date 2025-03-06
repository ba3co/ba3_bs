import 'dart:isolate';

import '../../../core/helper/enums/enums.dart';
import '../../bond/data/models/entry_bond_model.dart';
import '../data/models/account_model.dart';
import '../service/account_statement_service.dart';

// process_entry_bond_items_in_isolate_use_case
class ProcessEntryBondItemsInIsolateUseCase {
  final AccountStatementService _accountStatementService;

  ProcessEntryBondItemsInIsolateUseCase(this._accountStatementService);

  /// Runs _processEntryBondItems in an Isolate for better performance
  Future<List<EntryBondItemModel>> execute(Map<AccountEntity, List<EntryBondItems>> data) async {
    final ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(_processEntryBondItemsIsolate, [receivePort.sendPort, data]);

    return await receivePort.first as List<EntryBondItemModel>;
  }

  /// Function that runs in the isolate
  void _processEntryBondItemsIsolate(List<dynamic> args) {
    final SendPort sendPort = args[0];
    final Map<AccountEntity, List<EntryBondItems>> data = args[1];

    final List<EntryBondItemModel> result = _processEntryBondItems(data);

    sendPort.send(result);
  }

  /// Processes entry bond items in a background isolate
  List<EntryBondItemModel> _processEntryBondItems(Map<AccountEntity, List<EntryBondItems>> result) {
    final Map<String, EntryBondItemModel> mergedMap = {};

    for (var entryList in result.values) {
      for (var entryBond in entryList) {
        for (var currentItem in entryBond.itemList) {
          final String key = currentItem.account.id;

          if (mergedMap.containsKey(key)) {
            final existingItem = mergedMap[key]!;

            double updatedAmount = _accountStatementService.getAmountSign(existingItem.amount!, existingItem.bondItemType!) +
                _accountStatementService.getAmountSign(currentItem.amount, currentItem.bondItemType!);

            BondItemType finalType = updatedAmount >= 0 ? BondItemType.debtor : BondItemType.creditor;

            mergedMap[key] = EntryBondItemModel(
              account: currentItem.account,
              amount: updatedAmount.abs(),
              bondItemType: finalType,
              date: currentItem.date,
              note: '${existingItem.note} + ${currentItem.note}',
              originId: currentItem.originId,
              docId: currentItem.docId,
            );
          } else {
            mergedMap[key] = currentItem;
          }
        }
      }
    }

    return mergedMap.values.toList();
  }
}
