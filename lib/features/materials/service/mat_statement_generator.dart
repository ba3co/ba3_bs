import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/materials/controllers/mats_statement_controller.dart';
import 'package:ba3_bs/features/materials/data/models/mat_statement/mat_statement_model.dart';
import 'package:ba3_bs/features/materials/service/mat_statement_creator_factory.dart';

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../bill/data/models/bill_items.dart';
import 'mat_statement_creator.dart';

mixin MatsStatementsGenerator {
  final MaterialsStatementController _materialsStatementController = read<MaterialsStatementController>();

  Future<void> generateAndSaveMatsStatements({
    required List sourceModels,
    void Function(double progress)? onProgress,
  }) async {
    final matsStatementsModels = _generateMatsStatementsModels(sourceModels);

    await _materialsStatementController.saveAllMatsStatementsModels(
      matsStatements: matsStatementsModels,
      onProgress: onProgress,
    );
  }

  List<MatStatementModel> _generateMatsStatementsModels(List sourceModels) {
    return sourceModels.expand<MatStatementModel>(
      (model) {
        final MatStatementCreator creator = MatStatementCreatorFactory.resolveMatStatementCreator(model);
        return creator.createMatStatement(model: model);
      },
    ).toList();
  }

  Future<void> generateAndSaveMatStatement<T>({
    required T model,
    Map<String, List<BillItem>> deletedMaterials = const {},
  }) async {
    final MatStatementCreator creator = MatStatementCreatorFactory.resolveMatStatementCreator(model);
    final matsStatementsModels = creator.createMatStatement(model: model);

    await _materialsStatementController.saveAllMatsStatementsModels(matsStatements: matsStatementsModels);

    if (deletedMaterials.isNotEmpty) {
      final originId = matsStatementsModels.first.originId;

      final matStatementsToDelete = deletedMaterials.entries.map((entry) {
        final matId = entry.key;
        final matStatementModel = matsStatementsModels.firstWhere((matStatement) => matStatement.matId == entry.key);

        return MatStatementModel(matId: matId, originId: originId, quantity: matStatementModel.quantity);
      }).toList();

      await _materialsStatementController.deleteAllMatStatementModel(matStatementsToDelete);
    }
  }

  Future<void> deleteMatsStatementsModels(BillModel billModel) async {
    final String originId = billModel.billId!;

    final matMatStatementsModels = billModel.items.itemList
        .map(
          (item) => MatStatementModel(
            matId: item.itemGuid,
            originId: originId,
            quantity: item.itemQuantity,
          ),
        )
        .toList();

    final groupedMatMatStatementsModels = matMatStatementsModels.mergeBy(
      (item) => item.matId,
      (existing, current) => MatStatementModel(
        matId: existing.matId,
        originId: existing.originId,
        quantity: existing.quantity! + current.quantity!,
      ),
    );

    await _materialsStatementController.deleteAllMatStatementModel(groupedMatMatStatementsModels);
  }
}
