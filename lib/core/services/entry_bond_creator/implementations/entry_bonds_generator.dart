import '../../../../features/accounts/data/models/account_model.dart';
import '../../../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../../features/bond/data/models/entry_bond_model.dart';
import '../../../helper/extensions/getx_controller_extensions.dart';
import '../interfaces/entry_bond_creator.dart';
import 'entry_bond_creator_factory.dart';

mixin EntryBondsGenerator {
  final EntryBondController entryBondController = read<EntryBondController>();

  Future<void> generateAndSaveEntryBondsFromModels<T>({
    required List sourceModels,
    void Function(double progress)? onProgress,
  }) async {
    final entryBondModels = _generateEntryBonds(sourceModels);

    await entryBondController.saveAllEntryBondModels(
      entryBonds: entryBondModels,
      onProgress: onProgress,
    );
  }

  Future<void> generateAndSaveEntryBondsFromModel<T>({
    required T model,
    Map<String, AccountModel> modifiedAccounts = const {},
    void Function(double progress)? onProgress,
  }) async {
    final entryBondModels = _generateEntryBond(model: model);

    if (entryBondModels.length == 1) {
      await entryBondController.saveEntryBondModel(
        entryBondModel: entryBondModels.first,
        modifiedAccounts: modifiedAccounts,
      );
    } else {
      await entryBondController.saveAllEntryBondModels(
        entryBonds: entryBondModels,
        onProgress: onProgress,
      );
    }
  }

  List<EntryBondModel> _generateEntryBonds<T>(List sourceModels) {
    return sourceModels.expand<EntryBondModel>((model) {
      final List<EntryBondCreator> creators = EntryBondCreatorFactory.resolveEntryBondCreators(model);
      return creators.map((creator) {
        return creator.createEntryBond(
          originType: EntryBondCreatorFactory.resolveOriginType(model),
          model: model,
        );
      });
    }).toList();
  }

  List<EntryBondModel> _generateEntryBond<T>({required T model}) {
    final List<EntryBondCreator> creators = EntryBondCreatorFactory.resolveEntryBondCreators(model);

    return creators
        .map(
          (creator) => creator.createEntryBond(
            originType: EntryBondCreatorFactory.resolveOriginType(model),
            model: model,
          ),
        )
        .toList();
  }
}
