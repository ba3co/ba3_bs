import '../../../features/bill/data/models/bill_model.dart';
import '../../../features/bill/services/bill/bill_entry_bond_creating_service.dart';
import '../../../features/bond/data/models/entry_bond_model.dart';
import '../enums/enums.dart';

mixin BillsEntryBondsGenerator on BillEntryBondService {
  List<EntryBondModel> generateEntryBonds(List<BillModel> bills) => bills
      .map(
        (bill) => createEntryBond(
          originType: EntryBondType.bill,
          billModel: bill,
          discountsAndAdditions: bill.billTypeModel.discountAdditionAccounts ?? const {},
          isSimulatedVat: false,
        ),
      )
      .toList();
}
