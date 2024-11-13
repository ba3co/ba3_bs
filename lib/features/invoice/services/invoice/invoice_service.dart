import 'package:ba3_bs/features/invoice/controllers/invoice_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:get/get.dart';

import '../../../bond/controllers/bond_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/invoice_pluto_controller.dart';
import '../../data/models/bill_model.dart';

class InvoiceService {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  InvoiceController get invoiceController => Get.find<InvoiceController>();

  SellerController get sellerController => Get.find<SellerController>();

  BondController get bondController => Get.find<BondController>();

  BillModel? createBillModel(BillModel? billModel, BillTypeModel billTypeModel) {
    if (invoiceController.selectedCustomerAccount == null || sellerController.selectedSellerAccount == null) {
      return null;
    }
    return BillModel.fromInvoiceData(
      billModel: billModel,
      billTypeModel: billTypeModel,
      note: null,
      billCustomerId: invoiceController.selectedCustomerAccount!.id!,
      billSellerId: sellerController.selectedSellerAccount!.costGuid!,
      billPayType: invoiceController.selectedPayType.index,
      billDate: invoiceController.billDate,
      billTotal: invoicePlutoController.calculateFinalTotal,
      billVatTotal: invoicePlutoController.computeTotalVat,
      billWithoutVatTotal: invoicePlutoController.computeWithoutVatTotal,
      billGiftsTotal: invoicePlutoController.computeGifts,
      billDiscountsTotal: invoicePlutoController.computeDiscounts,
      billAdditionsTotal: invoicePlutoController.computeAdditions,
      billItems: invoicePlutoController.generateInvoiceRecords,
    );
  }

  void createBond(BillTypeModel billTypeModel) => bondController.createBond(
        billTypeModel: billTypeModel,
        customerAccount: invoiceController.selectedCustomerAccount!,
        vat: invoicePlutoController.computeTotalVat,
        total: invoicePlutoController.computeWithoutVatTotal,
        gifts: invoicePlutoController.computeGifts,
        discount: invoicePlutoController.computeDiscounts,
        addition: invoicePlutoController.computeAdditions,
      );
}
