import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/bill/data/models/invoice_record_model.dart';
import 'package:ba3_bs/features/bond/controllers/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_record_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/dialogs/account_selection_dialog_content.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../../accounts/data/models/account_model.dart';

class BondRecordPlutoController extends IPlutoController {
  // Columns and rows
  late List<PlutoColumn> mainTableColumns = BondItemModel().toPlutoGridFormatWithType(bondType).keys.toList();

  List<PlutoRow> mainTableRows = [];

  final BondDetailsController bondDetailsController;
  final BondType bondType;

  BondRecordPlutoController(this.bondDetailsController, this.bondType);


  void onMainTableStateManagerChanged(PlutoGridOnChangedEvent event) {
    if (mainTableStateManager.currentRow == null) return;
    final String field = event.column.field;



    // Handle updates based on the changed column
    _handleColumnUpdate(field);

    safeUpdateUI();
  }

  void _handleColumnUpdate(String columnField) {
    if (columnField == "credit") {
      clearFiledInRow('debit');
    } else if (columnField == "debit") {
      clearFiledInRow('credit');
    } else if (columnField == "account") {
    setAccount();
    }
  }

  void clearFiledInRow(String filedName){

    updateCellValue(filedName, '');
  }


 void setAccount(){

    final query = mainTableStateManager.currentCell?.value ?? '';
    final accountsController = Get.find<AccountsController>();

    List<AccountModel> searchedAccounts = accountsController.getAccounts(query);
    AccountModel? selectedAccountModel;

    if (searchedAccounts.length == 1) {
      // Single match
      selectedAccountModel = searchedAccounts.first;
      updateCellValue("account",selectedAccountModel.accName);
    } else if (searchedAccounts.isEmpty) {
      // No matches
      updateCellValue("account",'');

    } else {
      // Multiple matches, show search dialog
      _showSearchDialog(
        // columnField: "account",
        // stateManager: mainTableStateManager,
        // controller: this,
        searchedAccounts: searchedAccounts,
      );
    }
  }


  void _showSearchDialog({
    required List<AccountModel> searchedAccounts,
  }) {
    Get.defaultDialog(
      // context: context,
      title: 'أختر الحساب',
      content: SizedBox(
        width: Get.width/2,
        height: Get.height,
        child: AccountSelectionDialogContent(
          accounts: searchedAccounts,
          onAccountTap: (selectedAccount) {

            updateCellValue("account",selectedAccount.accName);

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

    for (var element in mainTableStateManager.rows) {
      if (AppServiceUtils.getAccountModelFromLabel(element.toJson()["account"] ?? "") != null) {
        total += double.tryParse(element.toJson()["credit"] ?? "") ?? 0;
      }
    }

    return total;
  }

  double calcDebitTotal() {
    double total = 0;

    for (var element in mainTableStateManager.rows) {
      if (AppServiceUtils.getAccountModelFromLabel(element.toJson()["account"] ?? "") != null) {
        total += double.tryParse(element.toJson()["debit"] ?? "") ?? 0;
      }
    }

    return total;
  }

  setRows(List<BondItemModel> modelList) {
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
  }

  double getAmount(Map<String, PlutoCell> cells) {
    double amount = 0;

    if ((double.tryParse(cells["credit"]?.value)??0)> 0) {
      amount =double.tryParse(cells["credit"]?.value.toString()??'0' )??0;
    } else {
      amount = double.tryParse(cells["debit"]?.value.toString()??'0' )??0;
    }
    return amount;
  }

  BondItemType getBondItemType(Map<String, PlutoCell> cells) {
    BondItemType bondItemType = BondItemType.debtor;

    if ((double.tryParse(cells["credit"]?.value)??0)> 0) {
      bondItemType = BondItemType.creditor;
    } else {
      bondItemType = BondItemType.debtor;
    }
    return bondItemType;
  }

  BondModel get generateBondRecords {
    mainTableStateManager.setShowLoading(true);

    String bondCode = bondDetailsController.getLastBondCode();
    final bondRecord = mainTableStateManager.rows
        .map((row) {
          double amount = getAmount(row.cells);
          BondItemType bondItemType = getBondItemType(row.cells);

          return _processBondRow(
            amount: amount,
            note: row.cells['note']?.value,
            account: row.cells['account']?.value,
            bondType: bondItemType,
          );
        })
        .whereType<BondItemModel>()
        .toList();
    if ((bondDetailsController.bondType == BondType.credit)) {
      bondRecord.add(BondItemModel(
        bondItemType: BondItemType.creditor,
        note: bondDetailsController.noteController.text,
        amount: calcCreditTotal(),
        account: AppServiceUtils.getAccountModelFromLabel(bondDetailsController.accountController.text),
      ));
    } else {
      bondRecord.add(BondItemModel(
        bondItemType: BondItemType.debtor,
        note: bondDetailsController.noteController.text,
        amount: calcDebitTotal(),
        account: AppServiceUtils.getAccountModelFromLabel(bondDetailsController.accountController.text),
      ));
    }
    mainTableStateManager.setShowLoading(false);
    return BondModel(
      bonds: bondRecord,
      bondId: AppServiceUtils.generateUniqueId(),
      bondCode: bondCode,
      bondType: bondDetailsController.bondType,
    );
  }

  BondItemModel? _processBondRow({
    required String account,
    required String note,
    required BondItemType bondType,
    required double amount,
  }) {
    if (AppServiceUtils.getAccountModelFromLabel(account) != null) {
      return _createBondRecord(
        bondType: bondType,
        note: note,
        amount: amount,
        account: account,
      );
    }

    return null;
  }

  // Helper method to create an BondItemModel from a row
  BondItemModel _createBondRecord({
    required String account,
    required String note,
    required BondItemType bondType,
    required double amount,
  }) =>
      BondItemModel.fromJsonPluto(account: account, amount: amount, note: note, bondType: BondItemType.creditor);

  void updateCellValue(String field, dynamic value) {
    if(mainTableStateManager.currentRow!.cells[field]!=null) {
      mainTableStateManager.changeCellValue(
      mainTableStateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
    );
    }
    safeUpdateUI();
  }

  clearRowIndex(int rowIdx) {
    final rowToRemove = mainTableStateManager.rows[rowIdx];

    mainTableStateManager.removeRows([rowToRemove]);
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
  PlutoGridStateManager mainTableStateManager = PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  Color color = Colors.red;

  onMainTableLoaded(PlutoGridOnLoadedEvent event) {
    mainTableStateManager = event.stateManager;

    final newRows = mainTableStateManager.getNewRows(count: 30);
    mainTableStateManager.appendRows(newRows);

    if (mainTableStateManager.rows.isNotEmpty && mainTableStateManager.rows.first.cells.length > 1) {
      final secondCell = mainTableStateManager.rows.first.cells.entries.elementAt(1).value;
      mainTableStateManager.setCurrentCell(secondCell, 0);

      // FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
    }
  }

  @override
  PlutoGridStateManager get additionsDiscountsStateManager => throw UnimplementedError();

  @override
  String calculateAmountFromRatio(double ratio, double total) {
    // TODO: implement calculateAmountFromRatio
    throw UnimplementedError();
  }

  @override
  double get calculateFinalTotal => throw UnimplementedError();

  @override
  String calculateRatioFromAmount(double amount, double total) {
    throw UnimplementedError();
  }

  @override
  // TODO: implement computeAdditions
  double get computeAdditions => throw UnimplementedError();

  @override
  // TODO: implement computeBeforeVatTotal
  double get computeBeforeVatTotal => throw UnimplementedError();

  @override
  // TODO: implement computeDiscounts
  double get computeDiscounts => throw UnimplementedError();

  @override
  // TODO: implement computeGifts
  double get computeGifts => throw UnimplementedError();

  @override
  // TODO: implement computeGiftsTotal
  int get computeGiftsTotal => throw UnimplementedError();

  @override
  // TODO: implement computeTotalVat
  double get computeTotalVat => throw UnimplementedError();

  @override
  // TODO: implement computeWithVatTotal
  double get computeWithVatTotal => throw UnimplementedError();

  @override
  // TODO: implement generateBillRecords
  List<InvoiceRecordModel> get generateBillRecords => throw UnimplementedError();


  @override
  void moveToNextRow(PlutoGridStateManager stateManager, String cellField) {
    // TODO: implement moveToNextRow
  }

  @override
  void restoreCurrentCell(PlutoGridStateManager stateManager) {
    // TODO: implement restoreCurrentCell
  }

  void onRowSecondaryTap(PlutoGridOnRowSecondaryTapEvent event, BuildContext context) {}


}
