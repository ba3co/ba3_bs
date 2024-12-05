import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/bond/data/models/bond_record_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

class BondRecordPlutoController extends GetxController {
  BondRecordPlutoController(String type) {
    getColumns(type);
  }

  getColumns(String type) {
    {
      Map<PlutoColumn, dynamic> sampleData = BondItemModel( bondItemType: BondItemType.creditor, amount: 0.0, account: AccountModel(), oppositeAccount: AccountModel(), note: '').toPlutoGridFormat();
      columns = sampleData.keys.toList();
    }
    return columns;
  }

  getRows(List<BondItemModel> modelList, String type) {
    stateManager.removeAllRows();
    final newRows = stateManager.getNewRows(count: 30);

    if (modelList.isEmpty) {
      stateManager.appendRows(newRows);
      return rows;
    } else {
      rows = modelList.map((model) {
        Map<PlutoColumn, dynamic> rowData = model.toPlutoGridFormat();

        Map<String, PlutoCell> cells = {};

        rowData.forEach((key, value) {
          cells[key.field] = PlutoCell(value: value?.toString() ?? '');
        });

        return PlutoRow(cells: cells);
      }).toList();
    }

    stateManager.appendRows(rows);
    stateManager.appendRows(newRows);
    // print(rows.length);
    return rows;
  }

  List<PlutoRow> rows = [];
  late PlutoGridStateManager stateManager = PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());
  List<PlutoColumn> columns = [];

  void updateCellValue(String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
    );
  }

  double calcDebitTotal({bool? isDebit}) {
    double total = 0;
    if (isDebit == false) {
      total = calcCreditTotal();
    } else {
      for (var element in stateManager.rows) {
        // if (getAccountIdFromText(element.toJson()["bondRecAccount"] ?? "") != '') {
        //   total += double.tryParse(element.toJson()["bondRecDebitAmount"] ?? "") ?? 0.0;
        // }
      }
    }
    return total;
  }

  double calcCreditTotal({bool? isDebit}) {
    double total = 0;
    if (isDebit == true) {
      total = calcDebitTotal();
    } else {
      for (var element in stateManager.rows) {
        // if (getAccountIdFromText(element.toJson()["bondRecAccount"] ?? "") != '') {
        //   total += double.tryParse(element.toJson()["bondRecCreditAmount"] ?? "") ?? 0;
        // }
      }
    }
    return total;
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

  clearRowIndex(int rowIdx) {
    final rowToRemove = stateManager.rows[rowIdx];

    stateManager.removeRows([rowToRemove]);
    Get.back();
    update();
  }

  List<BondItemModel> handleSaveAll({bool? isCredit, String? account}) {
    stateManager.setShowLoading(true);
    List<BondItemModel> bondRecord = [];
    bondRecord = stateManager.rows
        .where((element) => element.cells['bondRecAccount']!.value != "")
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
    stateManager.setShowLoading(false);
    return bondRecord;
  }

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
