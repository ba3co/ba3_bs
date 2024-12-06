import 'package:ba3_bs/core/i_controllers/i_pluto_controller.dart';
import 'package:get/get.dart';

import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/bond_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';

class BillService {
  final IPlutoController plutoController;

  BillService(this.plutoController);

  BondController get bondController => Get.find<BondController>();

  BillModel? createBillModel({
    BillModel? billModel,
    required BillTypeModel billTypeModel,
    required String billCustomerId,
    required String billSellerId,
    required int billPayType,
    required String billDate,
  }) {
    return BillModel.fromBillData(
      billModel: billModel,
      billTypeModel: billTypeModel,
      note: null,
      billCustomerId: billCustomerId,
      billSellerId: billSellerId,
      billPayType: billPayType,
      billDate: billDate,
      billTotal: plutoController.calculateFinalTotal,
      billVatTotal: plutoController.computeTotalVat,
      billWithoutVatTotal: plutoController.computeBeforeVatTotal,
      billGiftsTotal: plutoController.computeGifts,
      billDiscountsTotal: plutoController.computeDiscounts,
      billAdditionsTotal: plutoController.computeAdditions,
      billRecordsItems: plutoController.generateBillRecords,
    );
  }

  void createBond({
    required BillTypeModel billTypeModel,
    required AccountModel customerAccount,
  }) =>
      bondController.createBillBond(
        billTypeModel: billTypeModel,
        customerAccount: customerAccount,
        vat: plutoController.computeTotalVat,
        total: plutoController.computeBeforeVatTotal,
        gifts: plutoController.computeGifts,
        discount: plutoController.computeDiscounts,
        addition: plutoController.computeAdditions,
      );
}
