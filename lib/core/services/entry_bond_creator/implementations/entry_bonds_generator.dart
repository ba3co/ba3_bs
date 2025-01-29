import '../../../../features/bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../../features/bond/data/models/entry_bond_model.dart';
import '../../../helper/extensions/getx_controller_extensions.dart';
import '../interfaces/entry_bond_creator.dart';
import '../interfaces/i_entry_bonds_generator.dart';
import 'entry_bond_creator_factory.dart';

class EntryBondsGenerator implements IEntryBondGenerator {
  @override
  List<EntryBondModel> createEntryBondsModels(List sourceModels) {
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
}

class EntryBondsGeneratorRepo {
  final IEntryBondGenerator entryBondGenerator;

  EntryBondsGeneratorRepo(this.entryBondGenerator);

  Future<void> saveEntryBonds({
    required List sourceModels,
    void Function(double progress)? onProgress,
  }) async {
    final entryBondModels = entryBondGenerator.createEntryBondsModels(sourceModels);

    await read<EntryBondController>().saveAllEntryBondModels(entryBonds: entryBondModels, onProgress: onProgress);
  }
}
