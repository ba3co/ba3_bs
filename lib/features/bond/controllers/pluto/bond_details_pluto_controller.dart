import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/i_controllers/i_table_pluto_controller.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/features/bond/controllers/bonds/bond_details_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/dialogs/account_selection_dialog_content.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../data/models/pay_item_model.dart';

class BondDetailsPlutoController extends IRecodesPlutoController<PayItem> {
  // Columns and rows
  late List<PlutoColumn> recordsTableColumns = PayItem().toPlutoGridFormat(bondType).keys.toList();

  List<PlutoRow> recordsTableRows = [];

  final BondDetailsController bondDetailsController;
  final BondType bondType;

  BondDetailsPlutoController(this.bondDetailsController, this.bondType);

  void onMainTableStateManagerChanged(PlutoGridOnChangedEvent event) {
    if (recordsTableStateManager.currentRow == null) return;
    final String field = event.column.field;

    // Handle updates based on the changed column
    _handleColumnUpdate(field);

    safeUpdateUI();
  }

  void _handleColumnUpdate(String columnField) {
    String correctedText =
        AppServiceUtils.extractNumbersAndCalculate(recordsTableStateManager.currentRow?.cells[columnField]?.value);
    if (columnField == AppConstants.entryCredit) {
      clearFiledInRow(AppConstants.entryDebit);
      updateCellValue(columnField, correctedText);
    } else if (columnField == AppConstants.entryDebit) {
      clearFiledInRow(AppConstants.entryCredit);
      updateCellValue(columnField, correctedText);
    } else if (columnField == AppConstants.entryAccountGuid) {
      setAccount(columnField);
    }
  }

  void clearFiledInRow(String filedName) {
    updateCellValue(filedName, '0');
  }

  void setAccount(String columnField) {
    final query = recordsTableStateManager.currentCell?.value ?? '';
    final accountsController = Get.find<AccountsController>();

    List<AccountModel> searchedAccounts = accountsController.getAccounts(query);
    AccountModel? selectedAccountModel;

    if (searchedAccounts.length == 1) {
      // Single match
      selectedAccountModel = searchedAccounts.first;
      updateCellValue(columnField, selectedAccountModel.accName);
    } else if (searchedAccounts.isEmpty) {
      // No matches
      updateCellValue(columnField, '');
    } else {
      // Multiple matches, show search dialog
      _showSearchDialog(
        columnField: columnField,
        // stateManager: mainTableStateManager,
        // controller: this,
        searchedAccounts: searchedAccounts,
      );
    }
  }

  void _showSearchDialog({
    required List<AccountModel> searchedAccounts,
    required String columnField,
  }) {
    Get.defaultDialog(
      // context: context,
      title: 'أختر الحساب',
      content: SizedBox(
        width: Get.width / 2,
        height: Get.height / 2,
        child: AccountSelectionDialogContent(
          accounts: searchedAccounts,
          onAccountTap: (selectedAccount) {
            updateCellValue(columnField, selectedAccount.accName);

            Get.back();
          },
        ),
      ),
    );
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
        update();
      });

  double calcCreditTotal() {
    double total = 0;

    for (var element in recordsTableStateManager.rows) {
      if (Get.find<AccountsController>().getAccountIdByName(element.toJson()[AppConstants.entryAccountGuid]) != '') {
        total += double.tryParse(element.toJson()[AppConstants.entryCredit] ?? "") ?? 0;
      }
    }

    return total;
  }

  double calcDebitTotal() {
    double total = 0;

    for (var element in recordsTableStateManager.rows) {
      if (Get.find<AccountsController>().getAccountIdByName(element.toJson()[AppConstants.entryAccountGuid]) != '') {
        total += double.tryParse(element.toJson()[AppConstants.entryDebit] ?? "") ?? 0;
      }
    }

    return total;
  }

/*  setRows(List<PayItem> modelList) {
    mainTableStateManager.removeAllRows();
    final newRows = mainTableStateManager.getNewRows(count: 30);

    if (modelList.isEmpty) {
      mainTableStateManager.appendRows(newRows);
      return mainTableRows;
    } else {
      mainTableRows = modelList.map((model) {
        Map<PlutoColumn, dynamic> rowData = model.toPlutoGridFormatWithType(bondDetailsController.bondType);

        Map<String, PlutoCell> cells = {};

        rowData.forEach((key, value) {
          cells[key.field] = PlutoCell(value: value?.toString() ?? '');
        });

        return PlutoRow(cells: cells);
      }).toList();
    }

    mainTableStateManager.appendRows(mainTableRows);
    mainTableStateManager.appendRows(newRows);
  }*/

  @override
  List<PayItem> get generateRecords {
    recordsTableStateManager.setShowLoading(true);
    final payItems = recordsTableStateManager.rows
        .where(
          (element) =>
              Get.find<AccountsController>().getAccountIdByName(element.cells[AppConstants.entryAccountGuid]?.value) !=
              '',
        )
        .map((row) {
          return _processBondRow(
            row: row.toJson(),
          );
        })
        .whereType<PayItem>()
        .toList();
    if (bondDetailsController.bondType == BondType.receiptVoucher) {
      // payItems.add(EntryBondItemModel(
      //   bondItemType: BondItemType.creditor,
      //   note: bondDetailsController.noteController.text,
      //   amount: calcCreditTotal(),
      //   account: AppServiceUtils.getAccountModelFromLabel(bondDetailsController.accountController.text),
      // ));
    } else if (bondDetailsController.bondType == BondType.paymentVoucher) {
      // payItems.add(EntryBondItemModel(
      //   bondItemType: BondItemType.debtor,
      //   note: bondDetailsController.noteController.text,
      //   amount: calcDebitTotal(),
      //   account: AppServiceUtils.getAccountModelFromLabel(bondDetailsController.accountController.text),
      // ));
    }
    recordsTableStateManager.setShowLoading(false);
    return payItems;
  }

  PayItem? _processBondRow({required Map<String, dynamic> row}) {
    return _createBondRecord(row: row);
  }

  // Helper method to create an BondItemModel from a row
  PayItem _createBondRecord({required Map<String, dynamic> row}) => PayItem.fromJsonPluto(row: row);

  void updateCellValue(String field, dynamic value) {
    if (recordsTableStateManager.currentRow!.cells[field] != null) {
      recordsTableStateManager.changeCellValue(
        recordsTableStateManager.currentRow!.cells[field]!,
        value,
        callOnChangedEvent: false,
        notify: true,
      );
    }
    safeUpdateUI();
  }

  clearRowIndex(int rowIdx) {
    final rowToRemove = recordsTableStateManager.rows[rowIdx];

    recordsTableStateManager.removeRows([rowToRemove]);
    Get.back();
    update();
  }

  bool checkIfBalancedBond() {
    if (getDefBetweenCreditAndDebt() == 0) {
      return true;
    } else {
      return false;
    }
  }

  double getDefBetweenCreditAndDebt() {
    return calcCreditTotal().toInt() - calcDebitTotal().toInt() * 1.0;
  }

  // State managers
  @override
  PlutoGridStateManager recordsTableStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  Color color = Colors.red;

  onMainTableLoaded(PlutoGridOnLoadedEvent event) {
    recordsTableStateManager = event.stateManager;

    final newRows = recordsTableStateManager.getNewRows(count: 30);
    recordsTableStateManager.appendRows(newRows);

    if (recordsTableStateManager.rows.isNotEmpty && recordsTableStateManager.rows.first.cells.length > 1) {
      final secondCell = recordsTableStateManager.rows.first.cells.entries.elementAt(1).value;
      recordsTableStateManager.setCurrentCell(secondCell, 0);
      event.stateManager.setKeepFocus(true);

      // FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
    }
  }

  void onRowSecondaryTap(PlutoGridOnRowSecondaryTapEvent event, BuildContext context) {}

  prepareBondMaterialsRows(List<PayItem> bondItems) {}
}
