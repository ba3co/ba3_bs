import 'package:ba3_bs/core/functions/functions.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/bill/data/models/invoice_record_model.dart';
import 'package:ba3_bs/features/bond/controllers/bond_details_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_record_model.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/i_controllers/i_pluto_controller.dart';

class BondRecordPlutoController extends IPlutoController {
  // Columns and rows
 late List<PlutoColumn> mainTableColumns = BondItemModel().toPlutoGridFormatWithType(  bondDetailsController.isDebitOrCredit).keys.toList();

  List<PlutoRow> mainTableRows = [];

  final BondDetailsController bondDetailsController;
  BondRecordPlutoController(this.bondDetailsController);


 double calcCreditTotal() {
  double total = 0;
  if (bondDetailsController.isDebitOrCredit == true) {
   total = calcDebitTotal();
  } else {
   for (var element in mainTableStateManager.rows) {
    if (Functions.getAccountModelFromLabel(element.toJson()["account"] ?? "") != null) {
     total += double.tryParse(element.toJson()["credit"] ?? "") ?? 0;
    }
   }
  }
  return total;
 }
 double calcDebitTotal() {
  double total = 0;
  if (bondDetailsController.isDebitOrCredit == true) {
   total = calcCreditTotal();
  } else {
   for (var element in mainTableStateManager.rows) {
    if (Functions.getAccountModelFromLabel(element.toJson()["account"] ?? "") != '') {
     total += double.tryParse(element.toJson()["debit"] ?? "") ?? 0;
    }
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
    Map<PlutoColumn, dynamic> rowData = model.toPlutoGridFormatWithType(bondDetailsController.isDebitOrCredit);

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
 List<BondItemModel> handleSaveAll({bool? isCredit, String? account}) {
  mainTableStateManager.setShowLoading(true);
  List<BondItemModel> bondRecord = [];
  bondRecord = mainTableStateManager.rows
      .where((element) => element.cells['account']!.value != "")
      .map(
       (e) => BondItemModel.fromPlutoJson(e.toJson()),
  )
      .toList();
  if (isCredit == true) {
   // bondRecord.add(
   //   BondRecordModel(
   //     (bondRecord.length + 1).toString(),
   //     0,
   //     calcCreditTotal(),
   //     getAccountIdFromText(account),
   //     "",
   //   ),
   // );
  } else if (isCredit == false) {
   // bondRecord.add(
   //   BondRecordModel(
   //     (bondRecord.length + 1).toString(),
   //     calcDebitTotal(),
   //     0,
   //     getAccountIdFromText(account),
   //     "",
   //   ),
   // );
  }
// print(invRecord.map((e) => e.toJson(),).toList());
  mainTableStateManager.setShowLoading(false);
  return bondRecord;
 }


/*





  void updateCellValue(String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
    );
  }


  clearRowIndex(int rowIdx) {
    final rowToRemove = stateManager.rows[rowIdx];

    stateManager.removeRows([rowToRemove]);
    Get.back();
    update();
  }




  bool checkIfBalancedBond({bool? isDebit}) {
    if (getDefBetweenCreditAndDebt(isDebit: isDebit) == 0) {
      return true;
    } else {
      return false;
    }
  }

  double getDefBetweenCreditAndDebt({bool? isDebit}) {
    return calcCreditTotal(isDebit: isDebit).toInt() - calcDebitTotal(isDebit: isDebit).toInt() * 1.0;
  }
  */


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

  get onMainTableStateManagerChanged => null;

  @override
  void moveToNextRow(PlutoGridStateManager stateManager, String cellField) {
    // TODO: implement moveToNextRow

  }

  @override
  void restoreCurrentCell(PlutoGridStateManager stateManager) {
    // TODO: implement restoreCurrentCell
  }

  void onRowSecondaryTap(PlutoGridOnRowSecondaryTapEvent event, BuildContext context) {}

/*  List<EntryBondRecordModel> handleSaveAllForEntry({bool? isCredit, String? account}) {
    stateManager.setShowLoading(true);
    List<EntryBondRecordModel> invRecord = [];
    invRecord = stateManager.rows
        .where((element) => getAccountIdFromText(element.cells['bondRecAccount']!.value) != "")
        .map(
          (e) => EntryBondRecordModel.fromPlutoJson(e.toJson()),
        )
        .toList();
    if (isCredit == true) {
      invRecord.add(
        EntryBondRecordModel(
          (invRecord.length + 1).toString(),
          0,
          calcCreditTotal(),
          getAccountIdFromText(account),
          "",
        ),
      );
    } else if (isCredit == false) {
      invRecord.add(
        EntryBondRecordModel(
          (invRecord.length + 1).toString(),
          calcDebitTotal(),
          0,
          getAccountIdFromText(account),
          "",
        ),
      );
    }

    stateManager.setShowLoading(false);
    return invRecord;
  }*/
}
