import 'package:ba3_bs/features/materials/controllers/mats_statement_controller.dart';
import 'package:ba3_bs/features/materials/data/models/mat_statement/mat_statement_model.dart';
import 'package:ba3_bs/features/materials/service/mat_statement_creator_factory.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import 'mat_statement_creator.dart';

class MatsStatementsGenerator {
  List<MatStatementModel> createMatsStatementsModels(List sourceModels) {
    return sourceModels.expand<MatStatementModel>(
      (model) {
        final MatStatementCreator creator = MatStatementCreatorFactory.resolveMatStatementCreator(model);
        return creator.createMatStatement(model: model);
      },
    ).toList();
  }
}

class MatStatementItemsGeneratorRepo {
  final MatsStatementsGenerator matsStatementsGenerator;

  MatStatementItemsGeneratorRepo(this.matsStatementsGenerator);

  Future<void> saveEntryBonds({
    required List sourceModels,
    void Function(double progress)? onProgress,
  }) async {
    final matsStatementsModels = matsStatementsGenerator.createMatsStatementsModels(sourceModels);

    await read<MaterialsStatementController>().saveAllMatsStatementsModels(
      matsStatements: matsStatementsModels,
      onProgress: onProgress,
    );
  }
}
