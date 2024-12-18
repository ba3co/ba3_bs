import 'dart:developer';

import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/e_invoice_dialog_content.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/pdf_base.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/discount_addition_account_model.dart';
import '../../data/models/invoice_record_model.dart';
import 'bill_bond_service.dart';
import 'bill_pdf_generator.dart';

class BillService with PdfBase, BillBondService {
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
    required BuildContext context,
    required BillTypeModel billTypeModel,
    required AccountModel customerAccount,
  }) =>
      bondController.createBillBond(
        context: context,
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

  Future<void> handleSaveOrUpdateSuccess({
    required BillModel billModel,
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
    required BillSearchController billSearchController,
    required bool isSave,
  }) async {
    final successMessage = isSave ? 'تم حفظ الفاتورة بنجاح!' : 'تم تعديل الفاتورة بنجاح!';

    AppUIUtils.onSuccess(successMessage);

    if (isSave) {
      billController.updateIsBillSaved = true;
    } else {
      billSearchController.updateBill(billModel);
    }

    generateAndSendPdf(
      fileName: AppStrings.bill,
      itemModel: billModel,
      itemModelId: billModel.billId,
      items: billModel.items.itemList,
      pdfGenerator: BillPdfGenerator(),
    );

    bondController.saveBillEntryBondModel(
      entryBondModel: createEntryBondModel(
        originType: EntryBondType.bill,
        billModel: billModel,
        discountsAndAdditions: discountsAndAdditions,
      ),
    );
  }

  showEInvoiceDialog(BillModel billModel, BuildContext context) {
    if (!hasModelId(billModel.billId)) return;

    OverlayService.showDialog(
      context: context,
      title: "Invoice QR Code",
      content: EInvoiceDialogContent(
        billController: billController,
        billId: billModel.billId!,
      ),
      onCloseCallback: () {
        log("E-Invoice dialog closed.");
      },
    );
  }
}
