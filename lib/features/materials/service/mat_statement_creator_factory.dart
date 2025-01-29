import 'package:ba3_bs/features/materials/data/models/mat_statement/mat_statement_model.dart';
import 'package:ba3_bs/features/materials/service/mat_statement_creator.dart';

import '../../../../features/bill/data/models/bill_model.dart';
import '../../../core/helper/enums/enums.dart';

class MatStatementCreatorFactory {
  static MatStatementCreator resolveMatStatementCreator<T>(T model) {
    if (model is BillModel) {
      // Returns a single BillEntryBondCreator wrapped in a list
      return BillMatStatementCreator();
    }
    throw UnimplementedError("No EntryBondCreator implementation for model of type ${model.runtimeType}");
  }

  static MatOrigin resolveOriginType<T>(T model) {
    if (model is BillModel) {
      return MatOrigin(
        originId: model.billId,
        originTypeId: model.billTypeModel.id,
        originType: MatOriginType.bill,
      );
    }
    throw UnimplementedError("No EntryBondType defined for model of type ${model.runtimeType}");
  }
}
