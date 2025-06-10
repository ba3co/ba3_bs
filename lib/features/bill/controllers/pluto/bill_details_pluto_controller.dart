import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_model_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';
import 'package:ba3_bs/features/patterns/data/models/bill_type_model.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/utils/app_service_utils.dart';
import '../../../customer/data/models/customer_model.dart';
import '../../data/models/bill_items.dart';
import '../../data/models/discount_addition_account_model.dart';
import '../../data/models/invoice_record_model.dart';
import '../../services/pluto/bill_pluto_calculator.dart';
import '../../services/pluto/bill_pluto_context_menu.dart';
import '../../services/pluto/bill_pluto_grid_service.dart';
import '../../services/pluto/bill_pluto_utils.dart';

class BillDetailsPlutoController extends IPlutoController<InvoiceRecordModel> {
  final BillTypeModel billTypeModel;

  BillDetailsPlutoController(this.billTypeModel);

  // Services
  late final BillPlutoGridService _gridService;
  late final BillPlutoCalculator _calculator;
  late final BillPlutoUtils _plutoUtils;
  late final BillPlutoContextMenu _contextMenu;

  late List<PlutoColumn> recordsTableColumns;

  // Columns and rows
  // List<PlutoColumn> recordsTableColumns = InvoiceRecordModel().toEditedMap(billTypeModel!).keys.toList();

  List<PlutoRow> recordsTableRows = [];

  List<PlutoRow> additionsDiscountsRows = [];

  List<PlutoColumn> additionsDiscountsColumns = AdditionsDiscountsRecordModel().toEditedMap().keys.toList();

  @override
  Map<MaterialModel, List<TextEditingController>> buyMaterialsSerialsControllers = {};

  @override
  Map<MaterialModel, List<TextEditingController>> sellMaterialsSerialsControllers = {};

  // State managers
  @override
  PlutoGridStateManager recordsTableStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  @override
  PlutoGridStateManager additionsDiscountsStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  @override
  String calculateAmountFromRatio(double ratio, double total) => _calculator.calculateAmountFromRatio(ratio, total).toStringAsFixed(2);

  @override
  String calculateRatioFromAmount(double amount, double total) => _calculator.calculateRatioFromAmount(amount, total).toStringAsFixed(2);

  @override
  double get computeWithVatTotal => _calculator.computeWithVatTotal;

  double get computeFirstPayTotal => _calculator.computeWithVatTotal;

  @override
  double get computeBeforeVatTotal => _calculator.computeBeforeVatTotal;

  @override
  double get computeTotalVat => _calculator.computeTotalVat;

  @override
  int get computeGiftsTotal => _calculator.computeGiftsTotal;

  @override
  double get computeGifts => _calculator.computeGifts;

  @override
  double get computeAdditions => _calculator.computeAdditions(_plutoUtils, computeWithVatTotal);

  @override
  double get calculateFinalTotal => _calculator.calculateFinalTotal(_plutoUtils);

  @override
  double get computeDiscounts => _calculator.computeDiscounts(_plutoUtils, computeWithVatTotal);

  @override
  List<InvoiceRecordModel> get generateRecords {
    recordsTableStateManager.setShowLoading(true);

    final materialController = read<MaterialController>();

    final List<InvoiceRecordModel> invoiceRecords =
        recordsTableStateManager.rows.map((row) => _processBillRow(row, materialController)).whereType<InvoiceRecordModel>().toList();

    generateSellMaterialsSerialsControllers(invoiceRecords);

    recordsTableStateManager.setShowLoading(false);

    return invoiceRecords;
  }

  Map<Account, List<DiscountAdditionAccountModel>> get generateDiscountsAndAdditions =>
      _gridService.collectDiscountsAndAdditions(_plutoUtils);

  @override
  void moveToNextRow(PlutoGridStateManager stateManager, String cellField) => _gridService.moveToNextRow(stateManager, cellField);

  @override
  void restoreCurrentCell(PlutoGridStateManager stateManager) => _gridService.restoreCurrentCell(stateManager, billTypeModel);

  void generateSellMaterialsSerialsControllers(List<InvoiceRecordModel> invRecords) {
    // Clear existing data to avoid duplicates
    sellMaterialsSerialsControllers.clear();

    for (final record in invRecords) {
      // Extract MaterialModel and serial number
      MaterialModel? material = read<MaterialController>().searchMaterialByName(record.invRecProduct);
      String? serialNumber = record.invRecProductSoldSerial;

      if (material != null && serialNumber != null && serialNumber.isNotEmpty) {
        // Ensure the material exists in the map
        sellMaterialsSerialsControllers.putIfAbsent(material, () => []);

        // Add the serial number as a TextEditingController
        sellMaterialsSerialsControllers[material]!.add(TextEditingController(text: serialNumber));
      }
    }

    // Log for debugging
    log('📌 Generated sellMaterialsSerialsControllers: ${sellMaterialsSerialsControllers.map((key, value) => MapEntry(key.toString(), value.map((controller) => controller.text).toList()))}');
  }

  @override
  void initSerialControllers(MaterialModel materialModel, int serialCount, BillItem billItem) {
    buyMaterialsSerialsControllers.update(
      materialModel,
      (existingList) => _matchControllerCount(existingList, serialCount, billItem),
      ifAbsent: () => _createControllers(serialCount, billItem),
    );
  }

  /// Ensures the [controllers] list has exactly [requiredCount] items.
  /// Adds [TextEditingController] instances if there are fewer than required,
  /// or disposes and removes any excess controllers.
  List<TextEditingController> _matchControllerCount(List<TextEditingController> controllers, int requiredCount, BillItem billItem) {
    final int currentCount = controllers.length;
    log(billItem.itemSerialNumbers.toString());
    if (currentCount < requiredCount) {
      // Add missing controllers and maintain existing values
      final int needed = requiredCount - currentCount;
      controllers.addAll(_createControllers(needed, billItem, startIndex: currentCount));
    } else if (currentCount > requiredCount) {
      // Dispose of and remove extras
      for (int i = requiredCount; i < currentCount; i++) {
        controllers[i].dispose();
      }
      controllers.removeRange(requiredCount, currentCount);
    }

    return controllers;
  }

  /// Creates a list of [TextEditingController] with [count] items,
  /// optionally starting from a specific index to ensure sequential serials.
  List<TextEditingController> _createControllers(int count, BillItem billItem, {int startIndex = 0}) {

    return List.generate(
      count,
      (index) {
        final actualIndex = startIndex + index;
        final text = (billItem.itemSerialNumbers != null && actualIndex < billItem.itemSerialNumbers!.length)
            ? billItem.itemSerialNumbers![actualIndex]
            : '';
        return TextEditingController(text: text);
      },
    );
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

    recordsTableColumns = InvoiceRecordModel().toEditedMap(billTypeModel).keys.toList();
  }

  void onMainTableLoaded(PlutoGridOnLoadedEvent event) {
    recordsTableStateManager = event.stateManager;
    recordsTableStateManager.setAutoEditing(true);
    final newRows = recordsTableStateManager.getNewRows(count: 30);
    recordsTableStateManager.appendRows(newRows);

    if (recordsTableStateManager.rows.isNotEmpty && recordsTableStateManager.rows.first.cells.length > 1) {
      final secondCell = recordsTableStateManager.rows.first.cells.entries.elementAt(1).value;
      recordsTableStateManager.setCurrentCell(secondCell, 0);

      FocusScope.of(event.stateManager.gridFocusNode.context!).requestFocus(event.stateManager.gridFocusNode);
    }

  }

  void onAdditionsDiscountsLoaded(PlutoGridOnLoadedEvent event) {
    additionsDiscountsStateManager = event.stateManager;

    final newRows = additionsDiscountsStateManager.getNewRows(count: 2);
    additionsDiscountsStateManager.appendRows(newRows);
  }

  void onMainTableStateManagerChanged(PlutoGridOnChangedEvent event, CustomerModel? customer) {
    log('onMainTableStateManagerChanged');

    if (recordsTableStateManager.currentRow == null) return;
    final String field = event.column.field;

    bool isPurchaseWithOutVat = billTypeModel.isPurchaseRelated && customer != null && customer.customerHasVat != true;
    // Extract and calculate values
    final quantity = _getQuantity();
    final subTotal = _getSubTotal();
    final total = _getTotal();
    final vat = isPurchaseWithOutVat ? 0.0 : _getVat();
    final subTotalWithVat = _getSubTotalWithVat();

    // Handle updates based on the changed column
    _handleColumnUpdate(field, quantity, subTotal, total, vat, subTotalWithVat, isPurchaseWithOutVat);

    safeUpdateUI();
  }

  void _handleColumnUpdate(
      String columnField, int quantity, double subTotal, double total, double vat, double subTotalWithVat, bool isPurchaseWithOutVat) {
    if (columnField == AppConstants.invRecSubTotal) {
      _gridService.updateInvoiceValues(subTotal, quantity, billTypeModel, isPurchaseWithOutVat);
    } else if (columnField == AppConstants.invRecTotal) {
      _gridService.updateInvoiceValuesByTotal(total, quantity, billTypeModel, isPurchaseWithOutVat);
    } else if (columnField == AppConstants.invRecQuantity && quantity > 0) {
      _gridService.updateInvoiceValuesByQuantity(
        quantity,
        subTotal,
        vat,
        billTypeModel,
      );
    } else if (columnField == AppConstants.invRecSubTotalWithVat && quantity > 0) {
      _gridService.updateInvoiceValuesBySubTotalWithVat(subTotalWithVat, quantity, billTypeModel, isPurchaseWithOutVat);
    }
    if (billTypeModel.billPatternType?.hasDiscountsAccount ?? true) {
      updateAdditionDiscountCell(computeWithVatTotal);
    }
  }

  double _getSubTotal() {
    final subTotalStr = _extractCellValueAsNumber(AppConstants.invRecSubTotal);
    return _plutoUtils.parseExpression(
      subTotalStr,
    );
  }

  double _getTotal() {
    final totalStr = _extractCellValueAsNumber(AppConstants.invRecTotal);
    return _plutoUtils.parseExpression(
      totalStr,
    );
  }

  int _getQuantity() {
    final quantityStr = _extractCellValueAsNumber(AppConstants.invRecQuantity);
    return _plutoUtils
        .parseExpression(
          quantityStr,
        )
        .toInt();
  }

  double _getVat() {
    final vatStr = _extractCellValueAsNumber(AppConstants.invRecVat);
    return vatStr.toDouble;
  }

  double _getSubTotalWithVat() {
    final subTotalWithVat = _extractCellValueAsNumber(AppConstants.invRecSubTotalWithVat);
    return subTotalWithVat.toDouble;
  }

  String _extractCellValueAsNumber(String field) {
    final cellValue = recordsTableStateManager.currentRow!.cells[field]?.value?.toString() ?? '';
    return AppServiceUtils.extractNumbersAndCalculate(cellValue);
  }

  void onMainTableRowSecondaryTap(PlutoGridOnRowSecondaryTapEvent event, BuildContext context, CustomerModel? customer) {
    bool isPurchaseWithOutVat = billTypeModel.isPurchaseRelated && customer != null && customer.customerHasVat != true;

    final materialName = event.row.cells[AppConstants.invRecProduct]?.value;
    if (materialName == null) return;

    final MaterialModel? materialModel = read<MaterialController>().getMaterialByName(materialName);
    if (materialModel == null) return;

    _handleContextMenu(event, materialModel, context, isPurchaseWithOutVat);
  }

  void _handleContextMenu(
      PlutoGridOnRowSecondaryTapEvent event, MaterialModel materialModel, BuildContext context, bool isPurchaseWithOutVat) {
    final field = event.cell.column.field;
    final row = event.row;

    if (field == AppConstants.invRecId) {
      _showDeleteConfirmationDialog(event, context);
    } else if (field == AppConstants.invRecProduct) {
      _showMatMenu(event, materialModel, context, row);
    } else if (field == AppConstants.invRecSubTotal) {
      _showPriceTypeMenu(event, materialModel, context, row, isPurchaseWithOutVat);
    }
  }

  void _showPriceTypeMenu(event, MaterialModel materialModel, BuildContext context, PlutoRow row, bool isPurchaseWithOutVat) {
    _contextMenu.showPriceTypeMenu(
        row: row,
        context: context,
        index: event.rowIdx,
        materialModel: materialModel,
        tapPosition: event.offset,
        invoiceUtils: _plutoUtils,
        gridService: _gridService,
        billTypeModel: billTypeModel,
        isPurchaseWithOutVat: isPurchaseWithOutVat);
  }

  List<String> get materialMenu => [
        'حركة المادة',
        'بطاقة المادة',
        if (billTypeModel.isPurchaseRelated) 'إضافة serial',
      ];

  void _showMatMenu(event, MaterialModel materialModel, BuildContext context, PlutoRow row) {
    final materialController = read<MaterialController>();

    final InvoiceRecordModel? invoiceRecordModel = _processBillRow(row, materialController);
log((invoiceRecordModel?.toJson()).toString(), name: 'InvoiceRecordModel');
    if (invoiceRecordModel == null) return;

    final billItem = BillItem.fromBillRecord(invoiceRecordModel);
    log(billItem.toJson().toString(), name: 'BillItem');

    _contextMenu.showMaterialMenu(
      materialMenu: materialMenu,
      context: context,
      billItem: billItem,
      index: event.rowIdx,
      materialModel: materialModel,
      tapPosition: event.offset,
      invoiceUtils: _plutoUtils,
      gridService: _gridService,
    );
  }

  void _showDeleteConfirmationDialog(event, BuildContext context) => _contextMenu.showDeleteConfirmationDialog(event.rowIdx, context);

  void onAdditionsDiscountsChanged(PlutoGridOnChangedEvent event) {
    log("onAdditionsDiscountsChanged");
    final field = event.column.field;
    final cells = event.row.cells;
    final row = event.row;
    final total = computeWithVatTotal;

    if (total == 0 || !_isRelevantField(field)) return;

    _updateAdditionsDiscountsCells(field, row, cells, total);
    safeUpdateUI();
  }

  bool _isRelevantField(String field) {
    return {
      AppConstants.discount,
      AppConstants.discountRatio,
      AppConstants.addition,
      AppConstants.additionRatio,
    }.contains(field);
  }

  void _updateAdditionsDiscountsCells(String field, PlutoRow row, Map<String, PlutoCell> cells, double total) {
    if (additionsDiscountsStateManager.rows.isEmpty) return;

    final inputValue = _plutoUtils.getCellValueInDouble(cells, field);
    if (inputValue == 0) return;

    final isRatioCell = _isRatioField(field);
    final targetField = _getTargetField(field, isRatioCell);

    final calculateNewValue = isRatioCell ? calculateAmountFromRatio : calculateRatioFromAmount;
    final newValue = calculateNewValue(inputValue, total);

    _gridService.updateAdditionsDiscountsCellValue(row.cells[field]!, inputValue);
    _gridService.updateAdditionsDiscountsCellValue(row.cells[targetField]!, newValue);
  }

  bool _isRatioField(String field) => field == AppConstants.discountRatio || field == AppConstants.additionRatio;

  String _getTargetField(String field, bool isRatioCell) {
    if (isRatioCell) {
      return field == AppConstants.discountRatio ? AppConstants.discount : AppConstants.addition;
    } else {
      return field == AppConstants.discount ? AppConstants.discountRatio : AppConstants.additionRatio;
    }
  }

  void updateAdditionDiscountCell(double total) => _gridService.updateAdditionDiscountCells(total, _plutoUtils);

  InvoiceRecordModel? _processBillRow(PlutoRow row, MaterialController materialController) {
    final materialModel = materialController.searchMaterialByName(row.cells[AppConstants.invRecProduct]!.value.toString());

    if (_plutoUtils.isValidItemQuantity(row, AppConstants.invRecQuantity) && materialModel != null) {
      if (billTypeModel.billPatternType?.hasVat ?? false) {
        return _createInvoiceRecord(row, materialModel.id!);
      } else {
        return _createInvoiceRecord(row, materialModel.id!);
      }
    }

    return null;
  }

  // Helper method to create an InvoiceRecordModel from a row
  InvoiceRecordModel _createInvoiceRecord(PlutoRow row, String matId) {
    return InvoiceRecordModel.fromJsonPluto(matId, row.toJson());
  }

  void prepareBillMaterialsRows(List<InvoiceRecordModel> invRecords) {
    recordsTableStateManager.removeAllRows();

    final newRows = recordsTableStateManager.getNewRows(count: 30);

    if (invRecords.isNotEmpty) {
      recordsTableRows = _gridService.convertRecordsToRows(invRecords, billTypeModel);

      recordsTableStateManager.appendRows(recordsTableRows);
      recordsTableStateManager.appendRows(newRows);
    } else {
      recordsTableRows = [];
      recordsTableStateManager.appendRows(newRows);
    }
  }

  void prepareAdditionsDiscountsRows(List<Map<String, String>> additionsDiscountsRecords) {
    additionsDiscountsStateManager.removeAllRows();

    if (additionsDiscountsRecords.isNotEmpty) {
      additionsDiscountsRows = _gridService.convertAdditionsDiscountsRecordsToRows(additionsDiscountsRecords);

      additionsDiscountsStateManager.appendRows(additionsDiscountsRows);
    } else {
      additionsDiscountsRows = [];
      additionsDiscountsStateManager.appendRows(_plutoUtils.emptyAdditionsDiscountsRecords());
    }
  }

  void safeUpdateUI() => WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then(
        (value) {
          update();
        },
      );

  @override
  void onClose() {
    for (var controllerList in buyMaterialsSerialsControllers.values) {
      for (final controller in controllerList) {
        controller.dispose();
      }
    }
  }

  clearVat() {
    _gridService.clearAllVatAndAddedToSubTotal(recordsTableStateManager, billTypeModel);
    safeUpdateUI();
  }

  returnVat() {
    _gridService.returnVatAndAddedToSubTotal(recordsTableStateManager, billTypeModel);
    safeUpdateUI();
  }

  /// this for mobile
/*  @override
  void updateWithSelectedMaterial({
    required MaterialModel? materialModel,
    required PlutoGridStateManager stateManager,
    required IPlutoController plutoController,
    required BillTypeModel billTypeModel,
  }) =>
      _gridService.updateWithSelectedMaterial(materialModel, stateManager, plutoController, billTypeModel);
 late BuildContext context;

  setContext(BuildContext context) {
    this.context = context;
  }
 */

}

// 530 - 236