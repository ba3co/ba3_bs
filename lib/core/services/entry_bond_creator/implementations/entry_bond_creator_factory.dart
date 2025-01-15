import '../../../../features/bill/data/models/bill_model.dart';
import '../../../../features/bill/services/bill/bill_entry_bond_creating_service.dart';
import '../../../../features/bond/data/models/bond_model.dart';
import '../../../../features/bond/service/bond/bond_entry_bond_service.dart';
import '../../../../features/cheques/data/models/cheques_model.dart';
import '../../../../features/cheques/service/cheques_bond_service.dart';
import '../interfaces/entry_bond_creator.dart';

class EntryBondCreatorFactory {
  static EntryBondCreator getService<T>(T model) {
    if (model is ChequesModel) {
      return ChequesEntryBondStrategyFactory().determineStrategy(chequesModel: model);
    } else if (model is BondModel) {
      return BondEntryBondService();
    } else if (model is BillModel) {
      return BillEntryBondService();
    }
    throw UnimplementedError("No service found for model type ${T.runtimeType}");
  }
}
