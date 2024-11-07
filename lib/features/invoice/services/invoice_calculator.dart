import 'dart:developer';

import 'package:ba3_bs/features/invoice/controllers/invoice_pluto_controller.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/utils.dart';

class InvoiceCalculator {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  PlutoGridStateManager get mainTableStateManager => invoicePlutoController.mainTableStateManager;

  double get computeWithVatTotal {
    double total = mainTableStateManager.rows.fold(0.0, (sum, record) {
      if (record.toJson()["invRecQuantity"] != '' && record.toJson()["invRecSubTotal"] != '') {
        return sum + (double.tryParse(record.toJson()["invRecTotal"].toString()) ?? 0);
      }
      return sum;
    });

    invoicePlutoController.updateVatTotalNotifier(total);

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

  double get computeTotalVat {
    double total = mainTableStateManager.rows.fold(
      0.0,
      (previousValue, record) {
        double vatAmount =
            double.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecVat"].toString())) ?? 0.0;
        int quantity =
            int.tryParse(Utils.replaceArabicNumbersWithEnglish(record.toJson()["invRecQuantity"].toString())) ?? 1;

        return previousValue + (vatAmount * quantity);
      },
    );
    log('computeTotalVat $total');
    return total;
  }

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

  double calculateDiscount(double total, double discountRate) {
    return total * (discountRate / 100);
  }

  double calculateDiscountAmount(String? discountRatioStr, total) {
    double discountRatio = double.tryParse(discountRatioStr ?? '') ?? 0.0;
    return total * (discountRatio / 100);
  }

  double calculateAdditionAmount(String? additionRatioStr, double total) {
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
}
