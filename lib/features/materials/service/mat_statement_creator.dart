import 'package:ba3_bs/core/helper/extensions/bill_items_extensions.dart';
import 'package:ba3_bs/features/materials/data/models/mat_statement/mat_statement_model.dart';

import '../../bill/data/models/bill_model.dart';
import '../../bill/services/bill/quantity_strategy.dart';
import '../../bill/services/bill/quantity_strategy_factory.dart';
import 'mat_statement_creator_factory.dart';

abstract class MatStatementCreator<T> {
  List<MatStatementModel> createMatStatement({required T model});
}

class BillMatStatementCreator implements MatStatementCreator<BillModel> {
  @override
  List<MatStatementModel> createMatStatement({required BillModel model}) {
    final QuantityStrategy quantityStrategy =
        QuantityStrategyFactory.getStrategy(model);

    final mergedItems = model.items.itemList.merge();

    return mergedItems
        .map(
          (matItem) => MatStatementModel(
            matOrigin: MatStatementCreatorFactory.resolveOriginType(model),
            matId: matItem.itemGuid,
            matName: matItem.itemName,
            originId: model.billId,
            quantity: quantityStrategy.calculateQuantity(matItem.itemQuantity),
            date: model.billDetails.billDate!,
            price: matItem.itemSubTotalPrice,
            note: '${model.billTypeModel.fullName}',
          ),
        )
        .toList();
  }
}
