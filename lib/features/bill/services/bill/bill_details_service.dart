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
import '../../../../core/helper/mixin/pdf_base.dart';
import '../../../../core/services/entry_bond_creator/implementations/entry_bond_creator_factory.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../bond/controllers/entry_bond/entry_bond_controller.dart';
import '../../../bond/ui/screens/entry_bond_details_screen.dart';
import '../../../floating_window/services/overlay_service.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/invoice_record_model.dart';
import 'bill_pdf_generator.dart';

class BillDetailsService with PdfBase, FloatingLauncher {
  final IPlutoController<InvoiceRecordModel> plutoController;
  final IBillController billController;

  BillDetailsService(this.plutoController, this.billController);

  EntryBondController get entryBondController => read<EntryBondController>();

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

  void launchFloatingEntryBondDetailsScreen({required BuildContext context, required BillModel billModel}) {
    if (!hasModelId(billModel.billId)) return;

    final creator = EntryBondCreatorFactory.resolveEntryBondCreator(billModel);

    final entryBondModel = creator.createEntryBond(
      isSimulatedVat: true,
      originType: EntryBondType.bill,
      model: billModel,
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

    entryBondController.deleteEntryBondModel(entryId: billModel.billId!);
  }

  Future<void> handleUpdateBillStatusSuccess({
    required BillModel updatedBillModel,
    required BillSearchController billSearchController,
  }) async {
    AppUIUtils.onSuccess('تم القبول بنجاح');
    billSearchController.updateBill(updatedBillModel);

    if (updatedBillModel.status == Status.approved &&
        updatedBillModel.billTypeModel.billPatternType!.hasCashesAccount) {
      final creator = EntryBondCreatorFactory.resolveEntryBondCreator(updatedBillModel);

      entryBondController.saveEntryBondModel(
        entryBondModel: creator.createEntryBond(
          isSimulatedVat: false,
          originType: EntryBondType.bill,
          model: updatedBillModel,
        ),
      );
    }
  }

  Map<String, AccountModel> findModifiedBillTypeAccounts({
    required BillModel previousBill,
    required BillModel currentBill,
  }) {
    // Extract the bill type models from the provided bills
    final previousBillTypeModel = previousBill.billTypeModel;
    final currentBillTypeModel = currentBill.billTypeModel;

    // Extract the accounts map or default to an empty map
    final previousAccounts = previousBillTypeModel.accounts ?? {};
    final currentAccounts = currentBillTypeModel.accounts ?? {};

    // Prepare a map to store accounts that have changed
    final modifiedAccounts = <String, AccountModel>{};

    // Iterate through the accounts in the previous bill
    previousAccounts.forEach((accountKey, previousAccountModel) {
      // Find the corresponding account in the current bill
      final currentAccountModel = currentAccounts[accountKey];

      // Check if the account exists in the current bill and has been modified
      if (currentAccountModel != null && currentAccountModel != previousAccountModel) {
        modifiedAccounts[accountKey.label] = previousAccountModel;
      }
    });
    log('modifiedAccounts length: ${modifiedAccounts.length}');

    modifiedAccounts
        .forEach((key, value) => log('modifiedBillTypeAccounts Account $key, AccountModel ${value.toJson()}'));

    // Return the map of modified accounts
    return modifiedAccounts;
  }

  Future<void> handleSaveOrUpdateSuccess({
    BillModel? previousBill,
    required BillModel currentBill,
    required BillSearchController billSearchController,
    required bool isSave,
  }) async {
    final successMessage = isSave ? 'تم حفظ الفاتورة بنجاح!' : 'تم تعديل الفاتورة بنجاح!';

    AppUIUtils.onSuccess(successMessage);

    Map<String, AccountModel> modifiedBillTypeAccounts = {};

    if (isSave) {
      billController.updateIsBillSaved = true;
    } else {
      modifiedBillTypeAccounts = findModifiedBillTypeAccounts(
        previousBill: previousBill!,
        currentBill: currentBill,
      );

      billSearchController.updateBill(currentBill);
    }

    generateAndSendPdf(
      fileName: AppStrings.bill,
      itemModel: currentBill,
      itemModelId: currentBill.billId,
      items: currentBill.items.itemList,
      pdfGenerator: BillPdfGenerator(),
    );

    if (currentBill.status == Status.approved && currentBill.billTypeModel.billPatternType!.hasMaterialAccount) {
      final creator = EntryBondCreatorFactory.resolveEntryBondCreator(currentBill);

      entryBondController.saveEntryBondModel(
        modifiedAccounts: modifiedBillTypeAccounts,
        entryBondModel: creator.createEntryBond(
          isSimulatedVat: false,
          originType: EntryBondType.bill,
          model: currentBill,
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
