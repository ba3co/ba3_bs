import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';
import 'package:ba3_bs/features/materials/ui/screens/material_statement_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/helper/mixin/app_navigator.dart';
import '../../../core/helper/mixin/floating_launcher.dart';
import '../../../core/services/firebase/implementations/repos/compound_datasource_repo.dart';
import '../../../core/utils/app_ui_utils.dart';
import '../data/models/mat_statement/mat_statement_model.dart';
import 'material_controller.dart';

class MaterialsStatementController extends GetxController with FloatingLauncher, AppNavigator {
  // Dependencies
  final CompoundDatasourceRepository<MatStatementModel, String> _matStatementsRepo;
  final MaterialController _materialsController = read<MaterialController>();

  MaterialsStatementController(this._matStatementsRepo);

  Future<void> saveAllMatsStatementsModels({
    required List<MatStatementModel> matsStatements,
    void Function(double progress)? onProgress,
  }) async {
    int counter = 0;
    for (final matStatement in matsStatements) {
      await saveMatStatementModel(matStatementModel: matStatement);

      await read<MaterialController>().updateMaterialQuantity(matStatement.matId!, matStatement.quantity!);

      onProgress?.call((++counter) / matsStatements.length);
    }
  }

  Future<void> saveMatStatementModel({required MatStatementModel matStatementModel}) async {
    final result = await _matStatementsRepo.save(matStatementModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (savedStatementModel) => AppUIUtils.onSuccess('تم الحفظ بنجاح'),
    );
  }

  Future<void> deleteMatStatementModel(MatStatementModel matStatementModel) async {
    final result = await _matStatementsRepo.delete(matStatementModel);

    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (_) => AppUIUtils.onSuccess('تم الحذف بنجاح'),
    );
  }

  Future<void> deleteAllMatStatementModel(List<MatStatementModel> matStatementsModels) async {
    final List<Future<void>> deletedTasks = [];
    final errors = <String>[];

    for (final matStatementModel in matStatementsModels) {
      deletedTasks.add(
        deleteMatStatementModel(matStatementModel),

        /*   _matStatementsRepo.delete(matStatementModel).then(
          (deleteResult) {
            deleteResult.fold(
              (failure) => errors.add(failure.message), // Collect errors.
              (_) {},
            );
          },
        ),*/
      );

      deletedTasks.add(read<MaterialController>().updateMaterialQuantity(matStatementModel.matId!, matStatementModel.quantity!));
    }

    await Future.wait(deletedTasks);

    if (errors.isNotEmpty) {
      AppUIUtils.onFailure('Some deletions failed: ${errors.join(', ')}');
    }
  }

  final List<MatStatementModel> matStatements = [];
  MaterialModel? selectedMat;

  bool isLoadingPlutoGrid = false;

  int totalQuantity = 0;

  bool isMatValid(MaterialModel? materialByName) {
    if (materialByName == null || materialByName.id == null) {
      AppUIUtils.onFailure('فشل في ايجاد الماده!');
      selectedMat = null;
      return false;
    }

    selectedMat = materialByName;
    return true;
  }

  Future<void> fetchMatStatements(String name, {required BuildContext context}) async {
    log('name $name');
    final materialByName = _materialsController.getMaterialByName(name);

    log('materialByName ${materialByName?.id}');

    if (!isMatValid(materialByName)) return;

    final result = await _matStatementsRepo.getAll(materialByName!.id!);
    result.fold(
      (failure) => AppUIUtils.onFailure(failure.message),
      (fetchedItems) {
        matStatements.assignAll(fetchedItems.map((item) => item).toList());

        launchFloatingWindow(
          context: context,
          floatingScreen: MaterialStatementScreen(),
          minimizedTitle: screenTitle,
        );
        // filterByDate();
        _calculateValues(fetchedItems);
      },
    );
  }

  /// Calculates debit, credit, and total values
  void _calculateValues(List<MatStatementModel> items) {
    if (items.isEmpty) {
      _resetValues();
    } else {
      _updateValues(items);
    }
  }

  _resetValues() {
    totalQuantity = 0;
  }

  _updateValues(List<MatStatementModel> items) {
    totalQuantity = _calculateSum(items);
  }

  int _calculateSum(List<MatStatementModel> items) => items.fold(
        0,
        (sum, item) => sum + (item.quantity ?? 0),
      );

  String get screenTitle => 'حركات ${selectedMat?.matName}';
}
