import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/e_invoice_dialog_content.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/i_controllers/pdf_base.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../bond/ui/screens/entry_bond_details_screen.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/discount_addition_account_model.dart';
import '../../data/models/invoice_record_model.dart';
import 'bill_entry_bond_creating_service.dart';
import 'bill_pdf_generator.dart';

class BillService with PdfBase, BillEntryBondCreatingService, FloatingLauncher {
  final IPlutoController<InvoiceRecordModel> plutoController;
  final IBillController billController;

  BillService(this.plutoController, this.billController);

  EntryBondController get bondController => read<EntryBondController>();

  BillModel? createBillModel({
    BillModel? billModel,
    required BillTypeModel billTypeModel,
    required String billCustomerId,
    required String billSellerId,
    required String? billNote,
    required int billPayType,
    required DateTime billDate,
  }) {
    return BillModel.fromBillData(
      billModel: billModel,
      billTypeModel: billTypeModel,
      status: RoleItemType.viewBill.status,
      note: billNote,
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

  void launchFloatingEntryBondDetailsScreen({
    required BuildContext context,
    required BillModel billModel,
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
  }) {
    if (!hasModelId(billModel.billId)) return;

    final entryBondModel = createEntryBondModel(
      isSimulatedVat: true,
      originType: EntryBondType.bill,
      billModel: billModel,
      discountsAndAdditions: discountsAndAdditions,
    );

    launchFloatingWindow(
      context: context,
      minimizedTitle: 'سند خاص ب ${BillType.byLabel(billModel.billTypeModel.billTypeLabel!).value}',
      floatingScreen: EntryBondDetailsScreen(entryBondModel: entryBondModel),
    );
  }

  Future<void> handleDeleteSuccess({
    required BillModel billModel,
    required BillSearchController billSearchController,
    bool fromBillById = false,
  }) async {
    // Only fetchBills if open bill details by bill id from AllBillsScreen
    if (fromBillById) {
      await read<AllBillsController>().fetchAllBillsByType(billModel.billTypeModel);
      Get.back();
    } else {
      billSearchController.removeBill(billModel);
    }

    AppUIUtils.onSuccess('تم حذف الفاتورة بنجاح!');

    bondController.deleteEntryBondModel(entryId: billModel.billId!);
  }

  Future<void> handleUpdateBillStatusSuccess({
    required BillModel updatedBillModel,
    required Map<Account, List<DiscountAdditionAccountModel>> discountsAndAdditions,
    required BillSearchController billSearchController,
  }) async {
    AppUIUtils.onSuccess('تم القبول بنجاح');
    billSearchController.updateBill(updatedBillModel);

    if (updatedBillModel.status == Status.approved &&
        updatedBillModel.billTypeModel.billPatternType!.hasCashesAccount) {
      bondController.saveEntryBondModel(
        entryBondModel: createEntryBondModel(
          isSimulatedVat: false,
          originType: EntryBondType.bill,
          billModel: updatedBillModel,
          discountsAndAdditions: discountsAndAdditions,
        ),
      );
    }
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

    if (billModel.status == Status.approved && billModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      bondController.saveEntryBondModel(
        entryBondModel: createEntryBondModel(
          isSimulatedVat: false,
          originType: EntryBondType.bill,
          billModel: billModel,
          discountsAndAdditions: discountsAndAdditions,
        ),
      );
    }
  }

  showEInvoiceDialog(BillModel billModel, BuildContext context) {
    if (!hasModelId(billModel.billId)) return;

    OverlayService.showDialog(
      context: context,
      title: 'Invoice QR Code',
      content: EInvoiceDialogContent(
        billController: billController,
        billId: billModel.billId!,
      ),
      onCloseCallback: () {
        log('E-Invoice dialog closed.');
      },
    );
  }
}
