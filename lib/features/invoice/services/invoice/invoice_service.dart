import 'package:get/get.dart';

import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/bond_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/invoice_pluto_controller.dart';
import '../../data/models/bill_model.dart';

class InvoiceService {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

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
      billTotal: invoicePlutoController.calculateFinalTotal,
      billVatTotal: invoicePlutoController.computeTotalVat,
      billWithoutVatTotal: invoicePlutoController.computeWithoutVatTotal,
      billGiftsTotal: invoicePlutoController.computeGifts,
      billDiscountsTotal: invoicePlutoController.computeDiscounts,
      billAdditionsTotal: invoicePlutoController.computeAdditions,
      billRecordsItems: invoicePlutoController.generateInvoiceRecords,
    );
  }

  void createBond({
    required BillTypeModel billTypeModel,
    required AccountModel customerAccount,
  }) =>
      bondController.createBond(
        billTypeModel: billTypeModel,
        customerAccount: customerAccount,
        vat: invoicePlutoController.computeTotalVat,
        total: invoicePlutoController.computeWithoutVatTotal,
        gifts: invoicePlutoController.computeGifts,
        discount: invoicePlutoController.computeDiscounts,
        addition: invoicePlutoController.computeAdditions,
      );
}
