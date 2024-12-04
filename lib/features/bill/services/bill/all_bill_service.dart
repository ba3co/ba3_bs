import '../../../../core/helper/enums/enums.dart';
import '../../data/models/bill_details.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/bill_model.dart';

class AllBillService {
  static List<BillModel> appendEmptyBillModel(List<BillModel> bills) {
    final List<BillModel> modifiedBills = bills;

    final BillModel lastBillModel = bills.last;

    final emptyBillModel = BillModel(
      billTypeModel: lastBillModel.billTypeModel,
      items: BillItems(itemList: []),
      billDetails: BillDetails(
        billPayType: InvPayType.cash.index,
        billDate: DateTime.now().toString().split(" ")[0],
        billNumber: lastBillModel.billDetails.billNumber! + 1,
      ),
    );
    modifiedBills.add(emptyBillModel);

    return modifiedBills;
  }
}
