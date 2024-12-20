import 'package:ba3_bs/core/helper/mixin/floating_launcher.dart';
import 'package:get/get.dart';

import '../../../../core/services/firebase/implementations/datasource_repo.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/datasources/remote/accounts_statements_data_source.dart';
import '../../data/models/entry_bond_model.dart';

class EntryBondController extends GetxController with FloatingLauncher {
  final DataSourceRepository<EntryBondModel> _entryBondsFirebaseRepo;

  final AccountsStatementsRepository _accountsStatementsRepo;

  EntryBondController(this._entryBondsFirebaseRepo, this._accountsStatementsRepo);

  // Method to create a bond based on bill type
  void saveEntryBondModel({
    required EntryBondModel entryBondModel,
  }) async {
    final result = await _entryBondsFirebaseRepo.save(entryBondModel, true);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) async {
        for (final item in entryBondModel.items!) {
          await _accountsStatementsRepo.addBond(item.accountId!, entryBondModel);
        }
      },
    );
  }

  // Method to create a bond based on bill type
  void deleteEntryBondModel({required String entryId}) async {
    final result = await _entryBondsFirebaseRepo.getById(entryId);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (entryBondModel) async {
        final List<Future<void>> deletedTasks = [];
        final errors = <String>[]; // Collect error messages.

        final entryBondModelAccountsToRemove = getEntryBondModelAccountsToRemove(entryBondModel);

        for (final accountId in entryBondModelAccountsToRemove) {
          deletedTasks.add(
            _accountsStatementsRepo.deleteBond(accountId, entryId).then((deleteResult) {
              deleteResult.fold(
                (failure) => errors.add(failure.message), // Collect errors.
                (_) {},
              );
            }),
          );
        }

        await Future.wait(deletedTasks);

        if (errors.isNotEmpty) {
          AppUIUtils.onFailure('Some deletions failed: ${errors.join(', ')}');
        }

        final deleteBondResult = await _entryBondsFirebaseRepo.delete(entryId);
        deleteBondResult.fold(
          (failure) => AppUIUtils.onFailure(failure.message),
          (_) {},
        );
      },
    );
  }

  List<String> getEntryBondModelAccountsToRemove(EntryBondModel entryBondModel) {
    final Set<String> accountsIds = <String>{}; // Use a Set to ensure unique account IDs.

    // Iterate through each EntryBondItemModel in the items list.
    for (final item in entryBondModel.items ?? []) {
      if (item.accountId != null) {
        accountsIds.add(item.accountId!);
      }
    }

    return accountsIds.toList(); // Convert the Set back to a List.
  }
}
