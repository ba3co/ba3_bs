import '../../data/models/bill_model.dart';

class AllBillService {
  static List<BillModel> appendEmptyBillModel(List<BillModel> bills) {
    final List<BillModel> modifiedBills = bills;

    final BillModel lastBillModel = bills.last;

    final emptyBillModel = BillModel.empty(
      billTypeModel: lastBillModel.billTypeModel,
      lastBillNumber: lastBillModel.billDetails.billNumber!,
    );

    modifiedBills.add(emptyBillModel);

    return modifiedBills;
  }
}
