import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/features/materials/data/models/mat_statement/mat_statement_model.dart';

import '../../bill/data/models/bill_items.dart';
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
    final QuantityStrategy quantityStrategy = QuantityStrategyFactory.getStrategy(model);

    final groupItems = groupItemsById(model.items.itemList);

    return groupItems
        .map(
          (matItem) => MatStatementModel(
            matOrigin: MatStatementCreatorFactory.resolveOriginType(model),
            matId: matItem.itemGuid,
            docId: model.billId,
            quantity: quantityStrategy.calculateQuantity(matItem.itemQuantity),
            date: model.billDetails.billDate!,
            price: matItem.itemSubTotalPrice,
            note: '${model.billTypeModel.fullName}',
          ),
        )
        .toList();
  }

  List<BillItem> groupItemsById(List<BillItem> itemList) => itemList.mergeBy(
        (item) => item.itemGuid,
        (existing, current) => BillItem(
          itemGuid: existing.itemGuid,
          itemName: existing.itemName,
          // Assuming name remains the same
          itemQuantity: existing.itemQuantity + current.itemQuantity,
          itemTotalPrice:
              (double.parse(existing.itemTotalPrice) + double.parse(current.itemTotalPrice)).toStringAsFixed(2),
          itemSubTotalPrice: (existing.itemSubTotalPrice ?? 0.0) + (current.itemSubTotalPrice ?? 0.0),
          itemVatPrice: (existing.itemVatPrice ?? 0.0) + (current.itemVatPrice ?? 0.0),
          itemGiftsNumber: (existing.itemGiftsNumber ?? 0) + (current.itemGiftsNumber ?? 0),
          itemGiftsPrice: (existing.itemGiftsPrice ?? 0.0) + (current.itemGiftsPrice ?? 0.0),
        ),
      );
}
