import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';

class AllBillService {
  static BillModel appendEmptyBillModel(List<BillModel> bills, BillTypeModel billTypeModel) {
    final int lastBillNumber = bills.isNotEmpty ? bills.last.billDetails.billNumber! : 0;

    final emptyBillModel = BillModel.empty(billTypeModel: billTypeModel, lastBillNumber: lastBillNumber);

    bills.add(emptyBillModel);
    return emptyBillModel;
  }
}
