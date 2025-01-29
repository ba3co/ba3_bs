import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/helper/mixin/floating_launcher.dart';
import 'package:ba3_bs/core/i_controllers/i_bill_controller.dart';
import 'package:ba3_bs/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs/core/services/entry_bond_creator/implementations/entry_bonds_generator.dart';
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
import '../../../materials/service/mat_statement_generator.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../../controllers/bill/all_bills_controller.dart';
import '../../data/models/bill_model.dart';
import '../../data/models/invoice_record_model.dart';

class BillDetailsService with PdfBase, EntryBondsGenerator, MatsStatementsGenerator, FloatingLauncher {
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
    required double billFirstPay,
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
      billFirstPay: billFirstPay,
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

    if (billModel.status == Status.approved && billModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      entryBondController.deleteEntryBondModel(entryId: billModel.billId!);
    }

    if (billModel.status == Status.approved) {
      deleteMatsStatementsModels(billModel);
    }
  }

  Future<void> handleUpdateBillStatusSuccess({
    required BillModel updatedBillModel,
    required BillSearchController billSearchController,
  }) async {
    AppUIUtils.onSuccess('تم القبول بنجاح');
    billSearchController.updateBill(updatedBillModel);

    if (updatedBillModel.status == Status.approved &&
        updatedBillModel.billTypeModel.billPatternType!.hasMaterialAccount) {
      generateAndSaveEntryBondsFromModel(model: updatedBillModel);

      // final creator = EntryBondCreatorFactory.resolveEntryBondCreator(updatedBillModel);
      //
      // entryBondController.saveEntryBondModel(
      //   entryBondModel: creator.createEntryBond(
      //     isSimulatedVat: false,
      //     originType: EntryBondType.bill,
      //     model: updatedBillModel,
      //   ),
      // );
    }

    if (updatedBillModel.status == Status.approved) {
      generateAndSaveMatsStatements(
        sourceModels: [updatedBillModel],
        onProgress: (progress) {
          log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
      );
    }
  }

  Map<String, AccountModel> findModifiedBillTypeAccounts({
    required BillModel previousBill,
    required BillModel currentBill,
  }) {
    // Extract accounts from the bill type models or default to empty maps
    final previousAccounts = previousBill.billTypeModel.accounts ?? {};
    final currentAccounts = currentBill.billTypeModel.accounts ?? {};

    // Identify accounts that are present in both bills but have changed
    final Map<String, AccountModel> modifiedAccounts = Map.fromEntries(
      previousAccounts.entries.where((MapEntry<Account, AccountModel> entry) {
        final currentAccount = currentAccounts[entry.key];
        return currentAccount != null && currentAccount != entry.value;
      }).map(
        // Use the account key's label for the map
        (entry) => MapEntry(entry.key.label, entry.value),
      ),
    );

    // Log modified accounts
    log('Modified accounts count: ${modifiedAccounts.length}');
    modifiedAccounts.forEach(
      (key, account) => log('Account Key: $key, Account Model: ${account.toJson()}'),
    );

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

      if (hasModelId(currentBill.billId) && hasModelItems(currentBill.items.itemList)) {
        generateAndSendPdf(
          fileName: AppStrings.newBill,
          itemModel: currentBill,
        );
      }
    } else {
      modifiedBillTypeAccounts = findModifiedBillTypeAccounts(previousBill: previousBill!, currentBill: currentBill);

      if (hasModelId(currentBill.billId) &&
          hasModelItems(currentBill.items.itemList) &&
          hasModelId(previousBill.billId) &&
          hasModelItems(previousBill.items.itemList)) {
        generateAndSendPdf(
          fileName: AppStrings.updatedBill,
          itemModel: [previousBill, currentBill],
        );
      }
    }

    billSearchController.updateBill(currentBill);

    if (currentBill.status == Status.approved && currentBill.billTypeModel.billPatternType!.hasMaterialAccount) {
      generateAndSaveEntryBondsFromModel(
        modifiedAccounts: modifiedBillTypeAccounts,
        model: currentBill,
      );

      // final creator = EntryBondCreatorFactory.resolveEntryBondCreator(currentBill);
      //
      // entryBondController.saveEntryBondModel(
      //   modifiedAccounts: modifiedBillTypeAccounts,
      //   entryBondModel: creator.createEntryBond(
      //     isSimulatedVat: false,
      //     originType: EntryBondType.bill,
      //     model: currentBill,
      //   ),
      // );
    }

    if (currentBill.status == Status.approved) {
      generateAndSaveMatsStatements(
        sourceModels: [currentBill],
        onProgress: (progress) {
          log('Progress: ${(progress * 100).toStringAsFixed(2)}%');
        },
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
