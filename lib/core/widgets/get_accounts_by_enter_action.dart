import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_pluto_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../features/accounts/controllers/accounts_controller.dart';
import '../../features/invoice/controllers/invoice_controller.dart';
import '../constants/app_constants.dart';
import '../helper/enums/enums.dart';

class GetAccountsByEnterAction extends PlutoGridShortcutAction {
  const GetAccountsByEnterAction(this.controller);

  final InvoicePlutoController controller;

  @override
  void execute({
    required PlutoKeyManagerEvent keyEvent,
    required PlutoGridStateManager stateManager,
  }) async {
    await getAccounts(stateManager, controller);
    // In SelectRow mode, the current Row is passed to the onSelected callback.
    if (stateManager.mode.isSelectMode && stateManager.onSelected != null) {
      stateManager.onSelected!(PlutoGridOnSelectedEvent(
        row: stateManager.currentRow,
        rowIdx: stateManager.currentRowIdx,
        cell: stateManager.currentCell,
        selectedRows: stateManager.mode.isMultiSelectMode ? stateManager.currentSelectingRows : null,
      ));
      return;
    }

    if (stateManager.configuration.enterKeyAction.isNone) {
      return;
    }

    if (!stateManager.isEditing && _isExpandableCell(stateManager)) {
      stateManager.toggleExpandedRowGroup(rowGroup: stateManager.currentRow!);
      return;
    }

    if (stateManager.configuration.enterKeyAction.isToggleEditing) {
      stateManager.toggleEditing(notify: false);
    } else {
      if (stateManager.isEditing == true || stateManager.currentColumn?.enableEditingMode == false) {
        final saveIsEditing = stateManager.isEditing;

        _moveCell(keyEvent, stateManager);

        stateManager.setEditing(saveIsEditing, notify: false);
      } else {
        stateManager.toggleEditing(notify: false);
      }
    }

    if (stateManager.autoEditing) {
      stateManager.setEditing(true, notify: false);
    }

    stateManager.notifyListeners();
  }

  /// Handles account selection and updates the grid cell value.
  Future<void> getAccounts(PlutoGridStateManager stateManager, InvoicePlutoController controller) async {
    final columnField = stateManager.currentColumn?.field;
    final rowIdValue = stateManager.currentRow?.cells[AppConstants.id]?.value;

    // Check if the selected column is 'discount' or 'addition' and the row is 'اسم الحساب'
    if ((columnField == AppConstants.discount || columnField == AppConstants.addition) &&
        rowIdValue == AppConstants.accountName) {
      final accountModel = await _openAccountSelectionDialog(stateManager.currentCell?.value);

      if (accountModel != null) {
        _updateSelectedAccount(columnField, accountModel);
        _updateCellValue(stateManager, columnField, accountModel.accName);
      } else {
        _resetCellValue(stateManager, columnField);
      }

      stateManager.notifyListeners();
      controller.update();
    }
  }

  /// Opens the account selection dialog and returns the selected account model.
  Future<AccountModel?> _openAccountSelectionDialog(String query) async =>
      await Get.find<AccountsController>().openAccountSelectionDialog(query: query);

  /// Updates the selected additions or discounts account based on the column field.
  void _updateSelectedAccount(String? columnField, AccountModel accountModel) {
    final invoiceController = Get.find<InvoiceController>();

    if (columnField == AppConstants.discount) {
      invoiceController.updateSelectedAdditionsDiscountAccounts(BillAccounts.discounts, accountModel);
    } else if (columnField == AppConstants.addition) {
      invoiceController.updateSelectedAdditionsDiscountAccounts(BillAccounts.additions, accountModel);
    }
  }

  /// Updates the value of the current cell.
  void _updateCellValue(PlutoGridStateManager stateManager, String? columnField, String? newValue) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[columnField]!,
      newValue,
      force: true,
      callOnChangedEvent: true,
      notify: true,
    );
  }

  /// Resets the value of the current cell to its original state.
  void _resetCellValue(PlutoGridStateManager stateManager, String? columnField) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[columnField]!,
      stateManager.currentCell?.value,
      callOnChangedEvent: false,
      notify: true,
    );
  }

  bool _isExpandableCell(PlutoGridStateManager stateManager) {
    return stateManager.currentCell != null &&
        stateManager.enabledRowGroups &&
        stateManager.rowGroupDelegate?.isExpandableCell(stateManager.currentCell!) == true;
  }

  void _moveCell(
    PlutoKeyManagerEvent keyEvent,
    PlutoGridStateManager stateManager,
  ) {
    final enterKeyAction = stateManager.configuration.enterKeyAction;

    if (enterKeyAction.isNone) {
      return;
    }

    // تحقق مما إذا كان في الخلية الأخيرة
    bool isLastCellInRow = stateManager.currentColumn?.field == stateManager.columns.last.field;
    bool isLastRow = stateManager.currentRowIdx == stateManager.rows.length - 1;

    if (enterKeyAction.isEditingAndMoveDown || enterKeyAction.isEditingAndMoveRight) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        // الانتقال للأعلى إذا كان Shift مضغوط
        stateManager.moveCurrentCell(
          PlutoMoveDirection.up,
          force: true,
          notify: true,
        );
      } else if (isLastCellInRow && !isLastRow) {
        // إذا كانت الخلية الأخيرة في السطر الحالي، انتقل إلى بداية السطر التالي
        stateManager.setCurrentCell(
          stateManager.rows[stateManager.currentRowIdx! + 1].cells[stateManager.columns.first.field],
          stateManager.currentRowIdx! + 1,
          notify: true,
        );
      } else {
        // إذا لم تكن في آخر خلية، انتقل إلى الخلية التالية
        stateManager.moveCurrentCell(
          PlutoMoveDirection.right,
          force: true,
          notify: true,
        );
      }
    } else if (enterKeyAction.isEditingAndMoveRight) {
      if (HardwareKeyboard.instance.isShiftPressed) {
        // الانتقال لليمين إذا كان Shift مضغوط
        stateManager.moveCurrentCell(
          PlutoMoveDirection.right,
          force: true,
          notify: false,
        );
      } else if (isLastCellInRow && !isLastRow) {
        // إذا كانت الخلية الأخيرة في السطر، انتقل إلى بداية السطر التالي
        stateManager.setCurrentCell(
          stateManager.rows[stateManager.currentRowIdx! + 1].cells[stateManager.columns.first.field],
          stateManager.currentRowIdx! + 1,
          notify: true,
        );
      } else {
        // الانتقال لليمين إذا لم تكن في آخر خلية
        stateManager.moveCurrentCell(
          PlutoMoveDirection.right,
          force: true,
          notify: false,
        );
      }
    }
  }
}
