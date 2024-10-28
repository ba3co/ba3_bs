import 'package:ba3_bs/core/constants/app_constants.dart';
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

  List<PlutoRow> rows = [];

// State manager for the main grid
  late PlutoGridStateManager stateManager =
      PlutoGridStateManager(columns: [], rows: [], gridFocusNode: FocusNode(), scroll: PlutoGridScrollController());

  // State manager for the additions and discounts grid
  late PlutoGridStateManager billAdditionsDiscountsStateManager;

  List<PlutoColumn> columns = [];
  String typeBile = '';
  String customerName = '';

  ValueNotifier<double> vatTotalNotifier = ValueNotifier<double>(0.0);

  PlutoGridOnChangedEvent? billAdditionsOnChangedEvent;

  getColumns() {
    Map<PlutoColumn, dynamic> sampleData = InvoiceRecordModel().toEditedMap();
    columns = sampleData.keys.toList();
    update();
    return columns;
  }

  clearRowIndex(int rowIdx) {
    final rowToRemove = stateManager.rows[rowIdx];

    stateManager.removeRows([rowToRemove]);
    Get.back();
    update();
  }

  getRows(List<InvoiceRecordModel> modelList) {
    stateManager.removeAllRows();
    final newRows = stateManager.getNewRows(count: 30);

    if (modelList.isEmpty) {
      stateManager.appendRows(newRows);
      return rows;
    } else {
      rows = modelList.map((model) {
        Map<PlutoColumn, dynamic> rowData = model.toEditedMap();

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

  double computeWithoutVatTotal() {
    int invRecQuantity = 0;
    double subtotals = 0.0;
    double total = 0.0;

    stateManager.setShowLoading(true);
    for (var record in stateManager.rows) {
      if (record.toJson()["invRecQuantity"] != '' &&
          record.toJson()["invRecSubTotal"] != '' &&
          (record.toJson()["invRecGift"] == '' || (int.tryParse(record.toJson()["invRecGift"] ?? "0") ?? 0) >= 0)) {
        invRecQuantity =
            int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecQuantity"].toString())) ?? 0;
        subtotals =
            double.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecSubTotal"].toString())) ?? 0;

        total += invRecQuantity * (subtotals);
      }
    }

    stateManager.setShowLoading(false);
    WidgetsFlutterBinding.ensureInitialized().waitUntilFirstFrameRasterized.then(
      (value) {
        // update();
      },
    );
    return total;
  }

  int computeGiftsTotal() {
    int total = 0;

    stateManager.setShowLoading(true);
    for (var record in stateManager.rows) {
      if (record.toJson()["invRecGift"] != null && record.toJson()["invRecGift"] != '') {
        total = int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecQuantity"].toString())) ?? 0;
      }
    }
    stateManager.setShowLoading(false);

    return total;
  }

  int computeRecordGiftsNumber(record) {
    int gifts = 0;

    stateManager.setShowLoading(true);

    if (record.toJson()["invRecGift"] != null && record.toJson()["invRecGift"] != '') {
      gifts = int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecGift"].toString())) ?? 0;
    }
    stateManager.setShowLoading(false);

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

  double computeWithVatTotal() {
    double total = 0.0;
    for (var record in stateManager.rows) {
      if (record.toJson()["invRecQuantity"] != '' && record.toJson()["invRecSubTotal"] != '') {
        total += double.tryParse(record.toJson()["invRecTotal"].toString()) ?? 0;
      }
    }

    vatTotalNotifier.value = total; // Update the ValueNotifier

    stateManager.setShowLoading(false);

    return total;
  }

  double computeGifts() {
    double total = 0.0;
    for (var record in stateManager.rows) {
      if (record.toJson()["invRecSubTotal"] != '' && record.toJson()["invRecGift"] != '') {
        total += computeRecordGiftsTotal(record);
      }
    }
    stateManager.setShowLoading(false);

    return total;
  }

  void updateCellValue(String field, dynamic value) {
    stateManager.changeCellValue(
      stateManager.currentRow!.cells[field]!,
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
    double vat = subTotal * 0.05;
    double total = subTotal * quantity;
    updateCellValue("invRecVat", vat.toStringAsFixed(2));
    updateCellValue("invRecSubTotal", (subTotal - vat).toStringAsFixed(2));
    updateCellValue("invRecTotal", total.toStringAsFixed(2));
    updateCellValue("invRecQuantity", quantity);
  }

  void updateInvoiceValuesByTotal(double total, int quantity) {
    double subTotal = (total / quantity) - ((total * 0.05) / quantity);
    double vat = ((total / quantity) - subTotal);

    updateCellValue("invRecVat", vat.toStringAsFixed(2));
    updateCellValue("invRecSubTotal", subTotal.toStringAsFixed(2));
    updateCellValue("invRecTotal", total.toStringAsFixed(2));
  }

  double parseExpression(String expression) {
    return Parser().parse(expression).evaluate(EvaluationType.REAL, ContextModel());
  }

  double computeDiscounts() {
    debugPrint('computeDiscounts');
    double discount = 0;

    // Fetch the discount ratio from billAdditionsDiscountsRows
    for (var row in AppConstants.billAdditionsDiscountsRows) {
      if (row.cells['discountRatioId']?.value != null && row.cells['discountRatioId']?.value != '') {
        // Parse the discount ratio and calculate the discount
        double discountRatio = double.tryParse(row.cells['discountRatioId']!.value) ?? 0;
        discount += computeWithVatTotal() * (discountRatio / 100); // Assuming discountRatio is a percentage
      }
    }

    return discount;
  }

  // Function to handle changes in the additions and discounts table
  void onAdditionsDiscountsChanged(PlutoGridOnChangedEvent event) async {
    billAdditionsOnChangedEvent = event;

    // Only handle changes to the 'discountRatioId' field
    if (event.column.field == 'discountRatioId') {
      // Calculate and update the discount amount based on the event
      double discountAmount =
          _calculateDiscountAmount(event.row.cells['discountRatioId']?.value, computeWithVatTotal());

      // Update the 'discountId' cell with the calculated discount
      billAdditionsDiscountsStateManager.changeCellValue(
        event.row.cells['discountId']!,
        discountAmount.toStringAsFixed(2),
      );

      debugPrint('onAdditionsDiscountsChanged');
      update();
    } else if (event.column.field == 'additionRatioId') {
      // Calculate and update the discount amount based on the event
      double additionAmount =
          _calculateAdditionAmount(event.row.cells['additionRatioId']?.value, computeWithVatTotal());

      // Update the 'discountId' cell with the calculated discount
      billAdditionsDiscountsStateManager.changeCellValue(
        event.row.cells['additionId']!,
        additionAmount.toStringAsFixed(2),
      );

      debugPrint('onAdditionsDiscountsChanged');
      update();
    }
  }

  void updateAdditionDiscountCell(double total) {
    if (total != 0 && billAdditionsOnChangedEvent != null) {
      updateDiscountCell(total);
      updateAdditionCell(total);
    }
  }

  void updateDiscountCell(double total) {
    double discountAmount = _calculateDiscountAmount(
      billAdditionsOnChangedEvent!.row.cells['discountRatioId']?.value,
      total,
    );

    billAdditionsDiscountsStateManager.changeCellValue(
      billAdditionsOnChangedEvent!.row.cells['discountId']!,
      discountAmount.toStringAsFixed(2),
    );

    debugPrint('onAdditionsDiscountsChanged on updateDiscountCell');
  }

  void updateAdditionCell(double total) {
    double additionAmount = _calculateAdditionAmount(
      billAdditionsOnChangedEvent!.row.cells['additionRatioId']?.value,
      total,
    );

    billAdditionsDiscountsStateManager.changeCellValue(
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

  double computeAdditions() {
    double addition = 0;
    for (var row in AppConstants.billAdditionsDiscountsRows) {
      if (row.cells['additionRatioId']?.value != null && row.cells['additionRatioId']?.value != '') {
        double additionRatio = double.tryParse(row.cells['additionRatioId']!.value) ?? 0;
        addition += computeWithVatTotal() * (additionRatio / 100);
      }
    }
    return addition;
  }

  double calculateFinalTotal() {
    double totalIncludingVAT = computeWithVatTotal();
    double totalDiscount = computeDiscounts();
    double totalAdditions = computeAdditions();

    return totalIncludingVAT - totalDiscount + totalAdditions;
  }
}
