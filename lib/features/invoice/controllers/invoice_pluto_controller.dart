import 'dart:developer';

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
  InvoicePlutoController() {
    getColumns();
  }

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
  List<PlutoColumn> mainTableColumns = [];

  List<PlutoRow> mainTableRows = [];

  List<PlutoRow> additionsDiscountsRows = AppConstants.additionsDiscountsRows;

  List<PlutoColumn> additionsDiscountsColumns = AppConstants.additionsDiscountsColumns;

  // Invoice details
  String typeBile = '';

  String customerName = '';

  ValueNotifier<double> vatTotalNotifier = ValueNotifier<double>(0.0);

  PlutoGridOnChangedEvent? billAdditionsOnChangedEvent;

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

  updateMainTableStateManager(stateManager) {
    mainTableStateManager = stateManager;
    update();
  }

  updateAdditionsDiscountsStateManager(stateManager) {
    additionsDiscountsStateManager = stateManager;
    update();
  }

  getColumns() {
    Map<PlutoColumn, dynamic> sampleData = InvoiceRecordModel().toEditedMap();
    mainTableColumns = sampleData.keys.toList();
    update();
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
    var materialName = mainTableStateManager.currentRow?.cells['invRecProduct']?.value;
    log('invRecId $materialName');
    MaterialModel? materialModel = Get.find<MaterialController>().getMaterialFromName(materialName);
    if (materialModel != null) {
      if (event.cell.column.field == "invRecSubTotal") {
        contextMenu.showContextMenuSubTotal(
            index: event.rowIdx, materialModel: materialModel, tapPosition: event.offset, invoiceUtils: invoiceUtils);
      }
    }
  }

  void onAdditionsDiscountsChanged(PlutoGridOnChangedEvent event) {
    billAdditionsOnChangedEvent = event;

    final String field = event.column.field;
    final cells = event.row.cells;
    final total = computeWithVatTotal;

    if (field == 'discountRatioId') {
      final discountAmount = calculateDiscountAmount(cells['discountRatioId']?.value, total).toStringAsFixed(2);
      gridService.updateCellValue(additionsDiscountsStateManager, "discountId", discountAmount);
    } else if (field == 'additionRatioId') {
      final additionAmount = calculateAdditionAmount(cells['additionRatioId']?.value, total).toStringAsFixed(2);
      gridService.updateCellValue(additionsDiscountsStateManager, "additionId", additionAmount);
    }

    safeUpdateUI();
  }

  void updateAdditionDiscountCell(double total) {
    debugPrint('updateAdditionDiscountCell total: $total, billAdditionsOnChangedEvent: $billAdditionsOnChangedEvent');
    if (total != 0 && billAdditionsOnChangedEvent != null) {
      gridService.updateDiscountCell(total);
      gridService.updateAdditionCell(total);
    }
  }

  // Method to clear cell values of additions and discounts rows
  void clearAdditionsDiscountsCells() {
    // Iterate only over the rows and clear non-accountId cells in one pass
    for (PlutoRow row in AppConstants.additionsDiscountsRows) {
      for (MapEntry<String, PlutoCell> entry in row.cells.entries) {
        if (entry.key != 'accountId') {
          entry.value.value = '';
        }
      }
    }
  }

  List<InvoiceRecordModel> handleSaveAllMaterials() {
    mainTableStateManager.setShowLoading(true);

    final materialController = Get.find<MaterialController>();

    final invoiceRecords = mainTableStateManager.rows
        .map((row) {
          final materialModel = materialController.getMaterialFromName(row.cells['invRecProduct']!.value);
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
    mainTableStateManager.removeAllRows();

    if (additionsDiscountsRecords.isNotEmpty) {
      additionsDiscountsRows = gridService.convertAdditionsDiscountsRecordsToRows(additionsDiscountsRecords);
    }
    additionsDiscountsStateManager.appendRows(additionsDiscountsRows);
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
        update();
      });

  double get computeWithVatTotal => calculator.computeWithVatTotal;

  updateVatTotalNotifier(double total) => vatTotalNotifier.value = total;

  double get computeWithoutVatTotal => calculator.computeWithoutVatTotal;

  double get computeTotalVat => calculator.computeTotalVat;

  int get computeGiftsTotal => calculator.computeGiftsTotal;

  double get computeGifts => calculator.computeGifts;

  double calculateDiscount(double total, double discountRate) => calculator.calculateDiscount(total, discountRate);

  double calculateDiscountAmount(String? discountRatioStr, double total) =>
      calculator.calculateDiscountAmount(discountRatioStr, total);

  double calculateAdditionAmount(String? additionRatioStr, double total) =>
      calculator.calculateAdditionAmount(additionRatioStr, total);

  double get computeAdditions => calculator.computeAdditions;

  double get calculateFinalTotal => calculator.calculateFinalTotal;

  double get computeDiscounts => calculator.computeDiscounts;

  @override
  void onClose() {
    super.onClose();
    clearAdditionsDiscountsCells(); // Clear cell values when the controller is closed
  }
}

// 530
