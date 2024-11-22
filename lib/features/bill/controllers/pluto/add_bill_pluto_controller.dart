import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/i_controllers/i_pluto_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/utils/app_service_utils.dart';
import '../../data/models/invoice_record_model.dart';
import '../../services/bill_pluto/bill_pluto_calculator.dart';
import '../../services/bill_pluto/bill_pluto_context_menu.dart';
import '../../services/bill_pluto/bill_pluto_grid_service.dart';
import '../../services/bill_pluto/bill_pluto_utils.dart';

class AddBillPlutoController extends IPlutoController {
  // Services
  late final BillPlutoGridService _gridService;
  late final BillPlutoCalculator _calculator;
  late final BillPlutoUtils _plutoUtils;
  late final BillPlutoContextMenu _contextMenu;

  // Columns and rows
  List<PlutoColumn> mainTableColumns = InvoiceRecordModel().toEditedMap().keys.toList();

  List<PlutoRow> mainTableRows = [];

  List<PlutoRow> additionsDiscountsRows = AppConstants.additionsDiscountsRows;

  List<PlutoColumn> additionsDiscountsColumns = AppConstants.additionsDiscountsColumns;

  // Invoice details
  String typeBile = '';

  String customerName = '';

  ValueNotifier<double> vatTotalNotifier = ValueNotifier<double>(0.0);

  // State managers
  @override
  PlutoGridStateManager mainTableStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  @override
  PlutoGridStateManager additionsDiscountsStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  @override
  updateVatTotalNotifier(double total) =>
      WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
        vatTotalNotifier.value = total;
      });

  @override
  String calculateAmountFromRatio(double ratio, double total) =>
      _calculator.calculateAmountFromRatio(ratio, total).toStringAsFixed(2);

  @override
  String calculateRatioFromAmount(double amount, double total) =>
      _calculator.calculateRatioFromAmount(amount, total).toStringAsFixed(2);

  @override
  double get computeWithVatTotal => _calculator.computeWithVatTotal;

  @override
  double get computeWithoutVatTotal => _calculator.computeWithoutVatTotal;

  @override
  double get computeTotalVat => _calculator.computeTotalVat;

  @override
  int get computeGiftsTotal => _calculator.computeGiftsTotal;

  @override
  double get computeGifts => _calculator.computeGifts;

  @override
  double get computeAdditions => _calculator.computeAdditions(_plutoUtils);

  @override
  double get calculateFinalTotal => _calculator.calculateFinalTotal(_plutoUtils);

  @override
  double get computeDiscounts => _calculator.computeDiscounts(_plutoUtils);

  @override
  List<InvoiceRecordModel> get generateBillRecords {
    mainTableStateManager.setShowLoading(true);

    final materialController = Get.find<MaterialController>();

    final invoiceRecords = mainTableStateManager.rows
        .map((row) => _processInvoiceRow(row, materialController))
        .whereType<InvoiceRecordModel>()
        .toList();

    mainTableStateManager.setShowLoading(false);
    return invoiceRecords;
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  // Initializer
  void _initializeServices() {
    _gridService = BillPlutoGridService(this);
    _calculator = BillPlutoCalculator(this);
    _plutoUtils = BillPlutoUtils(this);
    _contextMenu = BillPlutoContextMenu(this);
  }

  onMainTableLoaded(PlutoGridOnLoadedEvent event) {
    mainTableStateManager = event.stateManager;

    final newRows = mainTableStateManager.getNewRows(count: 30);
    mainTableStateManager.appendRows(newRows);

    if (mainTableStateManager.rows.isNotEmpty && mainTableStateManager.rows.first.cells.length > 1) {
      final secondCell = mainTableStateManager.rows.first.cells.entries.elementAt(1).value;
      mainTableStateManager.setCurrentCell(secondCell, 0);

      FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
    }
  }

  onAdditionsDiscountsLoaded(PlutoGridOnLoadedEvent event) {
    additionsDiscountsStateManager = event.stateManager;

    if (additionsDiscountsStateManager.rows.isNotEmpty && additionsDiscountsStateManager.rows.first.cells.length > 1) {
      final secondCell = additionsDiscountsStateManager.rows.first.cells.entries.elementAt(1).value;
      additionsDiscountsStateManager.setCurrentCell(secondCell, 0);

      FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
    }
  }

  void onMainTableStateManagerChanged(PlutoGridOnChangedEvent event) {
    final quantityNum = AppServiceUtils.extractNumbersAndCalculate(
        mainTableStateManager.currentRow!.cells[AppConstants.invRecQuantity]?.value?.toString() ?? '');

    final subTotalStr = AppServiceUtils.extractNumbersAndCalculate(
        mainTableStateManager.currentRow!.cells[AppConstants.invRecSubTotal]?.value);
    final totalStr = AppServiceUtils.extractNumbersAndCalculate(
        mainTableStateManager.currentRow!.cells[AppConstants.invRecTotal]?.value);
    final vat = AppServiceUtils.extractNumbersAndCalculate(
        mainTableStateManager.currentRow!.cells[AppConstants.invRecVat]?.value ?? "0");

    final double subTotal = _plutoUtils.parseExpression(subTotalStr);
    final double total = _plutoUtils.parseExpression(totalStr);
    final int quantity = double.parse(quantityNum).toInt();

    if (event.column.field == AppConstants.invRecSubTotal) _gridService.updateInvoiceValues(subTotal, quantity);
    if (event.column.field == AppConstants.invRecTotal) _gridService.updateInvoiceValuesByTotal(total, quantity);
    if (event.column.field == AppConstants.invRecQuantity && quantity > 0) {
      _gridService.updateInvoiceValuesByQuantity(quantity, subTotal, double.parse(vat));
    }

    safeUpdateUI();
  }

  void onMainTableRowSecondaryTap(PlutoGridOnRowSecondaryTapEvent event) {
    final materialName = event.row.cells[AppConstants.invRecProduct]?.value;
    if (materialName == null) return;

    final materialModel = Get.find<MaterialController>().getMaterialByName(materialName);
    if (materialModel == null) return;

    _handleContextMenu(event, materialModel);
  }

  void _handleContextMenu(PlutoGridOnRowSecondaryTapEvent event, MaterialModel materialModel) {
    final field = event.cell.column.field;
    if (field == AppConstants.invRecSubTotal) {
      _showSubTotalContextMenu(event, materialModel);
    } else if (field == AppConstants.invRecId) {
      _showDeleteConfirmationDialog(event);
    }
  }

  void _showSubTotalContextMenu(event, MaterialModel materialModel) {
    _contextMenu.showContextMenuSubTotal(
        index: event.rowIdx,
        materialModel: materialModel,
        tapPosition: event.offset,
        invoiceUtils: _plutoUtils,
        gridService: _gridService);
  }

  void _showDeleteConfirmationDialog(event) {
    _contextMenu.showDeleteConfirmationDialog(event.rowIdx);
  }

  void onAdditionsDiscountsChanged(PlutoGridOnChangedEvent event) {
    final String field = event.column.field;
    final cells = event.row.cells;
    final total = computeWithVatTotal;

    if (total == 0) return;

    if (field == AppConstants.discount || field == AppConstants.addition) {
      _updateCellValue(field, cells, total);
    }

    safeUpdateUI();
  }

  void _updateCellValue(String field, Map<String, PlutoCell> cells, double total) {
    if (additionsDiscountsStateManager.rows.isEmpty) return;

    double ratio = _plutoUtils.getCellValueInDouble(cells, field);

    if (ratio == 0) return;

    final newValue = calculateAmountFromRatio(ratio, total);

    final valueCell = _plutoUtils.valueRow.cells[field]!;

    _gridService.updateAdditionsDiscountsCellValue(valueCell, newValue);
  }

  void updateAdditionDiscountCell(double total) => _gridService.updateAdditionDiscountCells(total, _plutoUtils);

  InvoiceRecordModel? _processInvoiceRow(PlutoRow row, MaterialController materialController) {
    final materialModel = materialController.getMaterialByName(row.cells[AppConstants.invRecProduct]!.value);
    if (_plutoUtils.isValidItemQuantity(row, AppConstants.invRecQuantity) && materialModel != null) {
      return _createInvoiceRecord(row, materialModel.id!);
    }
    return null;
  }

  // Helper method to create an InvoiceRecordModel from a row
  InvoiceRecordModel _createInvoiceRecord(PlutoRow row, String matId) =>
      InvoiceRecordModel.fromJsonPluto(matId, row.toJson());

  void prepareMaterialsRows(List<InvoiceRecordModel> invRecords) {
    mainTableStateManager.removeAllRows();

    final newRows = mainTableStateManager.getNewRows(count: 30);

    if (invRecords.isNotEmpty) {
      mainTableRows = _gridService.convertRecordsToRows(invRecords);

      mainTableStateManager.appendRows(mainTableRows);
    }

    mainTableStateManager.appendRows(newRows);
  }

  void prepareAdditionsDiscountsRows(List<Map<String, String>> additionsDiscountsRecords) {
    additionsDiscountsStateManager.removeAllRows();

    final newRows = _plutoUtils.emptyAdditionsDiscountsRecords();

    if (additionsDiscountsRecords.isNotEmpty) {
      additionsDiscountsRows = _gridService.convertAdditionsDiscountsRecordsToRows(additionsDiscountsRecords);

      additionsDiscountsStateManager.appendRows(additionsDiscountsRows);
    } else {
      additionsDiscountsRows = newRows;
      additionsDiscountsStateManager.appendRows(additionsDiscountsRows);
    }
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
        update();
      });

  void clearAdditionsDiscountsCells() {
    for (int i = 1; i < AppConstants.additionsDiscountsRows.length; i++) {
      _clearRowCells(AppConstants.additionsDiscountsRows[i]);
    }
  }

  void _clearRowCells(PlutoRow row) {
    _clearCellValue(row, AppConstants.discount);
    _clearCellValue(row, AppConstants.addition);
  }

  void _clearCellValue(PlutoRow row, String cellKey) {
    final cell = row.cells[cellKey];
    if (cell?.value.isNotEmpty ?? false) cell?.value = '';
  }

  void resetAllTables() {
    // Clear all material and additions/discounts records in InvoicePlutoController
    prepareMaterialsRows([]);
    prepareAdditionsDiscountsRows([]);
    update();
  }

  @override
  void onClose() {
    super.onClose();
    clearAdditionsDiscountsCells();
  }
}

// 530

// 236
