import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_details_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/entryBond/entry_bond_controller.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/invoice_record_model.dart';

class BillService {
  final IPlutoController<InvoiceRecordModel> plutoController;
  final IBillController billController;

  BillService(this.plutoController, this.billController);

  EntryBondController get bondController => Get.find<EntryBondController>();

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
      billRecordsItems: plutoController.generateRecords,
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

  Future<void> handleDeleteSuccess(BillModel billModel, BillSearchController billSearchController,
      [fromBillById]) async {
    // Only fetchBills if open bill details by bill id from AllBillsScreen
    if (fromBillById) {
      await Get.find<AllBillsController>().fetchAllBills();
      Get.back();
    } else {
      billSearchController.removeBill(billModel);
    }

    AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!');
  }

  Future<void> handleSaveSuccess(BillModel billModel, BillDetailsController billDetailsController) async {
    AppUIUtils.onSuccess('تم حفظ الفاتورة بنجاح!');

    billDetailsController.updateIsBillSaved(true);

    billController.generateAndSendBillPdf(
      recipientEmail: AppStrings.recipientEmail,
      billModel: billModel,
      fileName: AppStrings.bill,
      logoSrc: AppAssets.ba3Logo,
      fontSrc: AppAssets.notoSansArabicRegular,
    );
  }

  void handleUpdateSuccess(BillModel billModel, BillSearchController billSearchController) {
    AppUIUtils.onSuccess('تم تعديل الفاتورة بنجاح!');

    billSearchController.updateBill(billModel);

    billController.generateAndSendBillPdf(
      recipientEmail: AppStrings.recipientEmail,
      billModel: billModel,
      fileName: AppStrings.bill,
      logoSrc: AppAssets.ba3Logo,
      fontSrc: AppAssets.notoSansArabicRegular,
    );
  }
}
