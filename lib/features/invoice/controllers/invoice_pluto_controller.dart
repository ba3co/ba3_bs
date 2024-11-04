import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/utils/utils.dart';
import '../data/models/invoice_record_model.dart';

class InvoicePlutoController extends GetxController {
  InvoicePlutoController() {
    getColumns();
  }

// State manager for the main grid
  late PlutoGridStateManager mainTableStateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  // State manager for the additions and discounts grid
  late PlutoGridStateManager additionsDiscountsStateManager;

  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];

  String typeBile = '';
  String customerName = '';

  ValueNotifier<double> vatTotalNotifier = ValueNotifier<double>(0.0);

  PlutoGridOnChangedEvent? billAdditionsOnChangedEvent;

  getColumns() {
    Map<PlutoColumn, dynamic> sampleData = InvoiceRecordModel().toEditedMap();
    columns = sampleData.keys.toList();
    update();
  }

  clearRowIndex(int rowIdx) {
    final rowToRemove = mainTableStateManager.rows[rowIdx];

    mainTableStateManager.removeRows([rowToRemove]);
    Get.back();
    update();
  }

  double get computeWithVatTotal {
    double total = mainTableStateManager.rows.fold(0.0, (sum, record) {
      if (record.toJson()["invRecQuantity"] != '' && record.toJson()["invRecSubTotal"] != '') {
        return sum + (double.tryParse(record.toJson()["invRecTotal"].toString()) ?? 0);
      }
      return sum;
    });

    vatTotalNotifier.value = total; // Update the ValueNotifier
    mainTableStateManager.setShowLoading(false);

    return total;
  }

  double get computeWithoutVatTotal {
    mainTableStateManager.setShowLoading(true);

    double total = mainTableStateManager.rows.fold(0.0, (sum, record) {
      String quantityStr = record.toJson()["invRecQuantity"].toString();
      String subTotalStr = record.toJson()["invRecSubTotal"].toString();
      String giftStr = record.toJson()["invRecGift"].toString();

      // Check conditions
      if (quantityStr.isNotEmpty && subTotalStr.isNotEmpty && (giftStr.isEmpty || (int.tryParse(giftStr) ?? 0) >= 0)) {
        int invRecQuantity = int.tryParse(Utils.replaceArabicNumbersWithEnglish(quantityStr)) ?? 0;
        double subTotal = double.tryParse(Utils.replaceArabicNumbersWithEnglish(subTotalStr)) ?? 0;
        return sum + (invRecQuantity * subTotal);
      }

      return sum;
    });

    mainTableStateManager.setShowLoading(false);
    return total;
  }

  double get computeTotalVat => mainTableStateManager.rows.fold(
        0.0,
        (previousValue, record) {
          double vatAmount =
              double.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecVat"].toString())) ?? 0.0;
          int quantity =
              int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecQuantity"].toString())) ?? 1;

          return previousValue + (vatAmount * quantity);
        },
      );

  int get computeGiftsTotal {
    mainTableStateManager.setShowLoading(true);

    int total = mainTableStateManager.rows.fold(0, (sum, record) {
      String giftValue = record.toJson()["invRecGift"] ?? '';
      if (giftValue.isNotEmpty) {
        int quantity =
            int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecQuantity"].toString())) ?? 0;
        return sum + quantity;
      }
      return sum;
    });

    mainTableStateManager.setShowLoading(false);
    return total;
  }

  int computeRecordGiftsNumber(record) {
    int gifts = 0;

    mainTableStateManager.setShowLoading(true);

    if (record.toJson()["invRecGift"] != null && record.toJson()["invRecGift"] != '') {
      gifts = int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecGift"].toString())) ?? 0;
    }
    mainTableStateManager.setShowLoading(false);

    return gifts;
  }

  double computeGiftPrice(record) {
    double itemSubTotal = double.tryParse(record.toJson()["invRecSubTotal"].toString())!;
    double itemVAt =
        double.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecVat"].toString())) ?? 0;

    return itemSubTotal + itemVAt;
  }

  double computeRecordGiftsTotal(record) {
    int recordGiftsNumber = computeRecordGiftsNumber(record);
    double giftPrice = computeGiftPrice(record);
    return recordGiftsNumber * giftPrice;
  }

  double get computeGifts {
    double total = mainTableStateManager.rows.fold(0.0, (sum, record) {
      if (record.toJson()["invRecSubTotal"] != '' && record.toJson()["invRecGift"] != '') {
        return sum + computeRecordGiftsTotal(record);
      }
      return sum;
    });

    return total;
  }

  void updateCellValue(String field, dynamic value) {
    mainTableStateManager.changeCellValue(
      mainTableStateManager.currentRow!.cells[field]!,
      value,
      callOnChangedEvent: false,
      notify: true,
      force: true,
    );
  }

  void updateInvoiceValuesByQuantity(int quantity, subtotal, double vat) {
    double total = (subtotal + vat) * quantity;

    updateCellValue("invRecTotal", total.toStringAsFixed(2));
  }

  void updateInvoiceValues(double subTotal, int quantity) {
    log('subTotal $subTotal ,quantity $quantity');

    double vat = subTotal * 0.05;
    double total = (subTotal + vat) * quantity;

    updateCellValue("invRecVat", vat.toStringAsFixed(2));
    updateCellValue("invRecSubTotal", subTotal.toStringAsFixed(2));
    updateCellValue("invRecTotal", total.toStringAsFixed(2));
    updateCellValue("invRecQuantity", quantity);
  }

  void updateInvoiceValuesByTotal(double total, int quantity) {
    double subTotal = total / (quantity * 1.05);
    double vat = subTotal * 0.05;

    updateCellValue("invRecVat", vat.toStringAsFixed(2));
    updateCellValue("invRecSubTotal", subTotal.toStringAsFixed(2));
    updateCellValue("invRecTotal", total.toStringAsFixed(2));
  }

  double parseExpression(String expression) {
    return Parser().parse(expression).evaluate(EvaluationType.REAL, ContextModel());
  }

  double get computeDiscounts {
    return AppConstants.additionsDiscountsRows.fold<double>(0, (discount, row) {
      final discountRatioValue = row.cells['discountRatioId']?.value;

      if (discountRatioValue != null && discountRatioValue.isNotEmpty) {
        final double discountRatio = double.tryParse(discountRatioValue) ?? 0;
        return discount + (computeWithVatTotal * (discountRatio / 100));
      }
      return discount; // Return the accumulated discount if the condition is not met
    });
  }

  void onMainTableStateManagerChanged(PlutoGridOnChangedEvent event) {
    String quantityNum = Utils.extractNumbersAndCalculate(
        mainTableStateManager.currentRow!.cells["invRecQuantity"]?.value?.toString() ?? '');
    String? subTotalStr =
        Utils.extractNumbersAndCalculate(mainTableStateManager.currentRow!.cells["invRecSubTotal"]?.value);
    String? totalStr = Utils.extractNumbersAndCalculate(mainTableStateManager.currentRow!.cells["invRecTotal"]?.value);
    String? vat = Utils.extractNumbersAndCalculate(mainTableStateManager.currentRow!.cells["invRecVat"]?.value ?? "0");

    double subTotal = parseExpression(subTotalStr);
    double total = parseExpression(totalStr);
    int quantity = double.parse(quantityNum).toInt();

    if (event.column.field == "invRecSubTotal") {
      updateInvoiceValues(subTotal, quantity);
    }
    if (event.column.field == "invRecTotal") {
      updateInvoiceValuesByTotal(total, quantity);
    }
    if (event.column.field == "invRecQuantity" && quantity > 0) {
      updateInvoiceValuesByQuantity(quantity, subTotal, double.parse(vat));
    }

    WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then(
      (value) {
        update();
      },
    );
  }

  void onMainTableRowSecondaryTap(event) {
    var materialName = mainTableStateManager.currentRow?.cells['invRecProduct']?.value;
    log('invRecId $materialName');
    MaterialModel? materialModel = Get.find<MaterialController>().getMaterialFromName(materialName);
    if (materialModel != null) {
      if (event.cell.column.field == "invRecSubTotal") {
        showContextMenuSubTotal(index: event.rowIdx, materialModel: materialModel, tapPosition: event.offset);
      }
    }
  }

  void showContextMenuSubTotal({
    required Offset tapPosition,
    required MaterialModel materialModel,
    required int index,
  }) {
    final menuItems = [
      {'label': 'سعر المستهلك', 'method': AppConstants.invoiceChoosePriceMethodeCustomerPrice},
      {'label': 'سعر الجملة', 'method': AppConstants.invoiceChoosePriceMethodeWholePrice},
      {'label': 'سعر المفرق', 'method': AppConstants.invoiceChoosePriceMethodeRetailPrice},
    ];

    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1.0,
        tapPosition.dy + 1.0,
      ),
      items: menuItems.map((menuItem) {
        return showContextMenuItem(
          index,
          materialModel,
          menuItem['label']!,
          menuItem['method']!,
        );
      }).toList(),
    );
  }

  PopupMenuItem showContextMenuItem(int index, MaterialModel materialModel, String text, String method) {
    return PopupMenuItem(
      enabled: true,
      child: ListTile(
        title: Text(
          "$text: ${getPrice(type: method, materialModel: materialModel).toStringAsFixed(2)}",
          textDirection: TextDirection.rtl,
        ),
      ),
      onTap: () {
        updateInvoiceValues(
          getPrice(materialModel: materialModel, type: method),
          int.tryParse(mainTableStateManager.rows[index].cells["invRecQuantity"]?.value.toString() ?? "1") ?? 1,
        );
        update();
      },
    );
  }

  double getPrice({required MaterialModel materialModel, required String type}) {
    double price = 0;

    switch (type) {
      case AppConstants.invoiceChoosePriceMethodeCustomerPrice:
        price = double.parse(materialModel.endUserPrice ?? "0");
        break;
      case AppConstants.invoiceChoosePriceMethodeWholePrice:
        price = double.parse(materialModel.wholesalePrice ?? "0");
        break;
      case AppConstants.invoiceChoosePriceMethodeRetailPrice:
        price = double.parse(materialModel.retailPrice ?? "0");
        break;

      default:
        throw ArgumentError("Unknown price method: $type");
    }

    return price;
  }

  // Function to handle changes in the additions and discounts table
  void onAdditionsDiscountsChanged(PlutoGridOnChangedEvent event) {
    billAdditionsOnChangedEvent = event;

    debugPrint('onAdditionsDiscountsChanged');

    // Only handle changes to the 'discountRatioId' field
    if (event.column.field == 'discountRatioId') {
      // Calculate and update the discount amount based on the event
      double discountAmount = _calculateDiscountAmount(event.row.cells['discountRatioId']?.value, computeWithVatTotal);

      // Update the 'discountId' cell with the calculated discount
      additionsDiscountsStateManager.changeCellValue(
        event.row.cells['discountId']!,
        discountAmount.toStringAsFixed(2),
      );

      updateIfFirstFrameRendered();
    } else if (event.column.field == 'additionRatioId') {
      // Calculate and update the discount amount based on the event
      double additionAmount = _calculateAdditionAmount(event.row.cells['additionRatioId']?.value, computeWithVatTotal);

      // Update the 'discountId' cell with the calculated discount
      additionsDiscountsStateManager.changeCellValue(
        event.row.cells['additionId']!,
        additionAmount.toStringAsFixed(2),
      );

      updateIfFirstFrameRendered();
    }
  }

  void updateAdditionDiscountCell(double total) {
    debugPrint(
        'updateAdditionDiscountCell total: ${total}, billAdditionsOnChangedEvent: ${billAdditionsOnChangedEvent}');
    if (total != 0 && billAdditionsOnChangedEvent != null) {
      updateDiscountCell(total);
      updateAdditionCell(total);
    }
  }

  void updateDiscountCell(double total) {
    String? discountRatioStr = billAdditionsOnChangedEvent!.row.cells['discountRatioId']?.value;
    if (discountRatioStr == null || discountRatioStr.isEmpty) {
      return;
    }
    double discountAmount = _calculateDiscountAmount(discountRatioStr, total);

    additionsDiscountsStateManager.changeCellValue(
      billAdditionsOnChangedEvent!.row.cells['discountId']!,
      discountAmount.toStringAsFixed(2),
    );

    debugPrint('onAdditionsDiscountsChanged on updateDiscountCell');
  }

  void updateAdditionCell(double total) {
    String? additionRatioStr = billAdditionsOnChangedEvent!.row.cells['additionRatioId']?.value;
    if (additionRatioStr == null || additionRatioStr.isEmpty) {
      return;
    }
    double additionAmount = _calculateAdditionAmount(
      billAdditionsOnChangedEvent!.row.cells['additionRatioId']?.value,
      total,
    );

    additionsDiscountsStateManager.changeCellValue(
      billAdditionsOnChangedEvent!.row.cells['additionId']!,
      additionAmount.toStringAsFixed(2),
    );

    debugPrint('onAdditionsDiscountsChanged on updateAdditionCell');
  }

  double _calculateDiscountAmount(String? discountRatioStr, double total) {
    double discountRatio = double.tryParse(discountRatioStr ?? '') ?? 0.0;
    return total * (discountRatio / 100);
  }

  double _calculateAdditionAmount(String? additionRatioStr, double total) {
    double additionRatio = double.tryParse(additionRatioStr ?? '') ?? 0.0;
    return total * (additionRatio / 100);
  }

  double get computeAdditions {
    return AppConstants.additionsDiscountsRows.fold<double>(0, (addition, row) {
      final additionRatioValue = row.cells['additionRatioId']?.value;

      if (additionRatioValue != null && additionRatioValue.isNotEmpty) {
        final double additionRatio = double.tryParse(additionRatioValue) ?? 0;
        return addition + (computeWithVatTotal * (additionRatio / 100));
      }
      return addition; // Return the accumulated addition if the condition is not met
    });
  }

  double get calculateFinalTotal {
    double totalIncludingVAT = computeWithVatTotal;
    double totalDiscount = computeDiscounts;
    double totalAdditions = computeAdditions;

    return totalIncludingVAT - totalDiscount + totalAdditions;
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

  void updateIfFirstFrameRendered() {
    WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then((value) {
      update();
    });
  }

  List<InvoiceRecordModel> handleSaveAllMaterials() {
    mainTableStateManager.setShowLoading(true);

    final materialController = Get.find<MaterialController>();

    final invoiceRecords = mainTableStateManager.rows
        .map((row) {
          final materialModel = materialController.getMaterialFromName(row.cells['invRecProduct']!.value);
          return _isRowValid(row, materialModel) ? _createInvoiceRecord(row, materialModel!.id!) : null;
        })
        .whereType<InvoiceRecordModel>()
        .toList();

    mainTableStateManager.setShowLoading(false);
    return invoiceRecords;
  }

// Helper method to validate each row
  bool _isRowValid(PlutoRow row, MaterialModel? materialModel) {
    final quantity = row.cells['invRecQuantity']?.value;
    return materialModel != null && quantity != null;
  }

// Helper method to create an InvoiceRecordModel from a row
  InvoiceRecordModel _createInvoiceRecord(PlutoRow row, String matId) {
    return InvoiceRecordModel.fromJsonPluto(matId, row.toJson());
  }

  @override
  void onClose() {
    super.onClose();
    clearAdditionsDiscountsCells(); // Clear cell values when the controller is closed
  }
}
