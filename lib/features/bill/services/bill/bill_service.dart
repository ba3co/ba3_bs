import 'package:ba3_bs/core/controllers/abstract/i_pluto_controller.dart';
import 'package:get/get.dart';

import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/bond_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';

class BillService {
  final IPlutoController controller;

  BillService(this.controller);

  BondController get bondController => Get.find<BondController>();

  BillModel? createBillModel({
    BillModel? billModel,
    required BillTypeModel billTypeModel,
    required String billCustomerId,
    required String billSellerId,
    required int billPayType,
    required String billDate,
  }) {
    return BillModel.fromInvoiceData(
      billModel: billModel,
      billTypeModel: billTypeModel,
      note: null,
      billCustomerId: billCustomerId,
      billSellerId: billSellerId,
      billPayType: billPayType,
      billDate: billDate,
      billTotal: controller.calculateFinalTotal,
      billVatTotal: controller.computeTotalVat,
      billWithoutVatTotal: controller.computeWithoutVatTotal,
      billGiftsTotal: controller.computeGifts,
      billDiscountsTotal: controller.computeDiscounts,
      billAdditionsTotal: controller.computeAdditions,
      billRecordsItems: controller.generateBillRecords,
    );
  }

  void createBond({
    required BillTypeModel billTypeModel,
    required AccountModel customerAccount,
  }) =>
      bondController.createBond(
        billTypeModel: billTypeModel,
        customerAccount: customerAccount,
        vat: controller.computeTotalVat,
        total: controller.computeWithoutVatTotal,
        gifts: controller.computeGifts,
        discount: controller.computeDiscounts,
        addition: controller.computeAdditions,
      );
}
