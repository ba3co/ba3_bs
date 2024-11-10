import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/utils/utils.dart';
import '../data/models/invoice_record_model.dart';
import '../services/invoice_calculator.dart';
import '../services/invoice_context_menu.dart';
import '../services/invoice_grid_service.dart';
import '../services/invoice_utils.dart';

class InvoicePlutoController extends GetxController {
  // Services
  late final InvoiceGridService gridService;
  late final InvoiceCalculator calculator;
  late final InvoiceUtils invoiceUtils;
  late final InvoiceContextMenu contextMenu;

  // State managers
  PlutoGridStateManager mainTableStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  PlutoGridStateManager additionsDiscountsStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  // Columns and rows
  List<PlutoColumn> mainTableColumns = InvoiceRecordModel().toEditedMap().keys.toList();

  List<PlutoRow> mainTableRows = [];

  List<PlutoRow> additionsDiscountsRows = AppConstants.additionsDiscountsRows;

  List<PlutoColumn> additionsDiscountsColumns = AppConstants.additionsDiscountsColumns;

  // Invoice details
  String typeBile = '';

  String customerName = '';

  ValueNotifier<double> vatTotalNotifier = ValueNotifier<double>(0.0);

  // Initializer
  void _initializeServices() {
    gridService = InvoiceGridService();
    calculator = InvoiceCalculator();
    invoiceUtils = InvoiceUtils();
    contextMenu = InvoiceContextMenu();
  }

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
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
    final quantityNum = Utils.extractNumbersAndCalculate(
        mainTableStateManager.currentRow!.cells["invRecQuantity"]?.value?.toString() ?? '');

    final subTotalStr =
        Utils.extractNumbersAndCalculate(mainTableStateManager.currentRow!.cells["invRecSubTotal"]?.value);
    final totalStr = Utils.extractNumbersAndCalculate(mainTableStateManager.currentRow!.cells["invRecTotal"]?.value);
    final vat = Utils.extractNumbersAndCalculate(mainTableStateManager.currentRow!.cells["invRecVat"]?.value ?? "0");

    final double subTotal = invoiceUtils.parseExpression(subTotalStr);
    final double total = invoiceUtils.parseExpression(totalStr);
    final int quantity = double.parse(quantityNum).toInt();

    if (event.column.field == "invRecSubTotal") gridService.updateInvoiceValues(subTotal, quantity);
    if (event.column.field == "invRecTotal") gridService.updateInvoiceValuesByTotal(total, quantity);
    if (event.column.field == "invRecQuantity" && quantity > 0) {
      gridService.updateInvoiceValuesByQuantity(quantity, subTotal, double.parse(vat));
    }

    safeUpdateUI();
  }

  void onMainTableRowSecondaryTap(event) {
    final materialName = mainTableStateManager.currentRow?.cells['invRecProduct']?.value;
    if (materialName == null) return;

    final materialModel = Get.find<MaterialController>().getMaterialByName(materialName);
    if (materialModel == null) return;

    _handleContextMenu(event, materialModel);
  }

  void _handleContextMenu(event, MaterialModel materialModel) {
    final field = event.cell.column.field;
    if (field == "invRecSubTotal") {
      _showSubTotalContextMenu(event, materialModel);
    } else if (field == "invRecId") {
      _showDeleteConfirmationDialog(event);
    }
  }

  void _showSubTotalContextMenu(event, MaterialModel materialModel) {
    contextMenu.showContextMenuSubTotal(
      index: event.rowIdx,
      materialModel: materialModel,
      tapPosition: event.offset,
      invoiceUtils: invoiceUtils,
    );
  }

  void _showDeleteConfirmationDialog(event) {
    contextMenu.showDeleteConfirmationDialog(event.rowIdx);
  }

  void onAdditionsDiscountsChanged(PlutoGridOnChangedEvent event) {
    final String field = event.column.field;
    final cells = event.row.cells;
    final total = computeWithVatTotal;

    if (total == 0) return;

    if (field == 'discount' || field == 'addition') {
      _updateCellValue(field, cells, total);
    }

    safeUpdateUI();
  }

  void _updateCellValue(String field, Map<String, PlutoCell> cells, double total) {
    if (additionsDiscountsStateManager.rows.isEmpty) return;

    double ratio = invoiceUtils.getCellValueInDouble(cells, field);

    if (ratio == 0) return;

    final newValue = calculateAmountFromRatio(ratio, total).toStringAsFixed(2);

    final valueCell = invoiceUtils.valueRow.cells[field]!;

    gridService.updateAdditionsDiscountsCellValue(valueCell, newValue);
  }

  void updateAdditionDiscountCell(double total) => gridService.updateAdditionDiscountCells(total);

  List<InvoiceRecordModel> handleSaveAllMaterials() {
    mainTableStateManager.setShowLoading(true);

    final materialController = Get.find<MaterialController>();

    final invoiceRecords = mainTableStateManager.rows
        .map((row) {
          final materialModel = materialController.getMaterialByName(row.cells['invRecProduct']!.value);
          return invoiceUtils.validateInvoiceRow(row, 'invRecQuantity') && materialModel != null
              ? _createInvoiceRecord(row, materialModel.id!)
              : null;
        })
        .whereType<InvoiceRecordModel>()
        .toList();

    mainTableStateManager.setShowLoading(false);
    return invoiceRecords;
  }

  // Helper method to create an InvoiceRecordModel from a row
  InvoiceRecordModel _createInvoiceRecord(PlutoRow row, String matId) =>
      InvoiceRecordModel.fromJsonPluto(matId, row.toJson());

  void loadMainTableRows(List<InvoiceRecordModel> invRecords) {
    mainTableStateManager.removeAllRows();
    final newRows = mainTableStateManager.getNewRows(count: 30);

    if (invRecords.isNotEmpty) {
      mainTableRows = gridService.convertRecordsToRows(invRecords);

      mainTableStateManager.appendRows(mainTableRows);
    }
    mainTableStateManager.appendRows(newRows);
  }

  void loadAdditionsDiscountsRows(List<Map<String, String>> additionsDiscountsRecords) {
    additionsDiscountsStateManager.removeAllRows();
    if (additionsDiscountsRecords.isNotEmpty) {
      additionsDiscountsRows = gridService.convertAdditionsDiscountsRecordsToRows(additionsDiscountsRecords);
    }

    additionsDiscountsStateManager.appendRows(additionsDiscountsRows);
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
        update();
      });

  updateVatTotalNotifier(double total) => vatTotalNotifier.value = total;

  double get computeWithVatTotal => calculator.computeWithVatTotal;

  double get computeWithoutVatTotal => calculator.computeWithoutVatTotal;

  double get computeTotalVat => calculator.computeTotalVat;

  int get computeGiftsTotal => calculator.computeGiftsTotal;

  double get computeGifts => calculator.computeGifts;

  double calculateDiscount(double total, double discountRate) => calculator.calculateDiscount(total, discountRate);

  double calculateAmountFromRatio(double discountRatio, double total) =>
      calculator.calculateAmountFromRatio(discountRatio, total);

  double calculateRatioFromAmount(double amount, double total) => calculator.calculateRatioFromAmount(amount, total);

  double get computeAdditions => calculator.computeAdditions;

  double get calculateFinalTotal => calculator.calculateFinalTotal;

  double get computeDiscounts => calculator.computeDiscounts;

  void _clearAdditionsDiscountsCells() {
    for (int i = 1; i < AppConstants.additionsDiscountsRows.length; i++) {
      _clearRowCells(AppConstants.additionsDiscountsRows[i]);
    }
  }

  void _clearRowCells(PlutoRow row) {
    _clearCellValue(row, 'discount');
    _clearCellValue(row, 'addition');
  }

  void _clearCellValue(PlutoRow row, String cellKey) {
    final cell = row.cells[cellKey];
    if (cell?.value.isNotEmpty ?? false) cell?.value = '';
  }

  @override
  void onClose() {
    super.onClose();
    _clearAdditionsDiscountsCells(); // Clear cell values when the controller is closed
  }
}

// 530

// 236
