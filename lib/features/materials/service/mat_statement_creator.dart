import 'package:ba3_bs/core/helper/extensions/bill/bill_items_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_model_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_type_model.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/mat_statement/mat_statement_model.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../bill/data/models/bill_items.dart';
import '../../bill/data/models/bill_model.dart';
import '../../bill/services/bill/quantity_strategy.dart';
import '../../bill/services/bill/quantity_strategy_factory.dart';
import 'mat_statement_creator_factory.dart';

abstract class MatStatementCreator<T> {
  List<MatStatementModel> createMatStatement({required T model, List<BillItem> updatedMaterials = const []});
}

class BillMatStatementCreator implements MatStatementCreator<BillModel> {
  @override
  List<MatStatementModel> createMatStatement({required BillModel model, List<BillItem> updatedMaterials = const []}) {
    final QuantityStrategy quantityStrategy = QuantityStrategyFactory.getStrategy(model);

    final mergedItems = model.items.itemList.merge();

    // Mapping over mergedItems to create a list of MatStatementModel instances
    return mergedItems.map((matItem) {
      final updatedModel = _getUpdatedModel(model, matItem);
      return MatStatementModel(
        matOrigin: MatStatementCreatorFactory.resolveOriginType(updatedModel),
        matId: matItem.itemGuid,
        matName: matItem.itemName,
        originId: model.billId,
        quantity: quantityStrategy.calculateQuantity(matItem.itemQuantity),
        date: model.billDetails.billDate!,
        price: _getStatementPrice(model, matItem),
        note: model.billTypeModel.fullName,
        defQuantity: _getStatementDefQuantity(matItem, updatedMaterials, quantityStrategy),
      );
    }).toList();
  }

  /// we need to min price instead of endUserPrice  to calculate in min price
  /// ex. mat min pris is 15 and we sela it at 30 after that we need to return this material
  /// we must to add it at main price to return without edit in main price
  double _getStatementPrice(BillModel model, BillItem matItem) {
    if (model.billTypeModel.isSalesReturn) {
      return read<MaterialController>().getMaterialById(matItem.itemGuid).calcMinPrice ?? 0;
    } else {
      return matItem.itemSubTotalPrice!;
    }
  }

// Helper function to update the bill model based on the material item
  BillModel _getUpdatedModel(BillModel model, BillItem matItem) {
    if (model.billTypeModel.isSellRelated) {
      if (AppConstants.forceFree != null) {
        return model.copyWith(freeBill: AppConstants.forceFree);
      }

      final currentMaterial = read<MaterialController>().getMaterialById(matItem.itemGuid);

      if ((currentMaterial.matLocalQuantity ?? 0) <= 0) {
        return model.copyWith(freeBill: true);
      } else {
        return model.copyWith(freeBill: false);
      }
    }
    return model;
  }

  /// The specified quantity is different when we update invoices
  /// other cases the quantity is the same as the quantity entered by the user.
  ///  in all cases we need to dirname quantity of material is it positive or negative
  int _getStatementDefQuantity(BillItem matItem, List<BillItem> updatedMaterials, QuantityStrategy quantityStrategy) =>
      quantityStrategy.calculateQuantity(updatedMaterials
              .firstWhereOrNull(
                (mat) => mat.itemGuid == matItem.itemGuid,
              )
              ?.itemQuantity ??
          matItem.itemQuantity);
}