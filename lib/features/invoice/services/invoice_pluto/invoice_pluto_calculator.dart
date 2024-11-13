import 'package:ba3_bs/features/invoice/controllers/invoice_pluto_controller.dart';
import 'package:get/get.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_service_utils.dart';
import 'invoice_pluto_utils.dart';

class InvoicePlutoCalculator {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  PlutoGridStateManager get mainTableStateManager => invoicePlutoController.mainTableStateManager;

  PlutoGridStateManager get additionsDiscountsStateManager => invoicePlutoController.additionsDiscountsStateManager;

  double get computeWithVatTotal {
    double total = mainTableStateManager.rows.fold(0.0, (sum, record) {
      if (record.toJson()[AppConstants.invRecQuantity] != '' && record.toJson()[AppConstants.invRecSubTotal] != '') {
        return sum + (double.tryParse(record.toJson()[AppConstants.invRecTotal].toString()) ?? 0);
      }
      return sum;
    });

    invoicePlutoController.updateVatTotalNotifier(total);

    return total;
  }

  double get computeWithoutVatTotal {
    mainTableStateManager.setShowLoading(true);

    double total = mainTableStateManager.rows.fold(0.0, (sum, record) {
      String quantityStr = record.toJson()[AppConstants.invRecQuantity].toString();
      String subTotalStr = record.toJson()[AppConstants.invRecSubTotal].toString();
      String giftStr = record.toJson()[AppConstants.invRecGift].toString();

      // Check conditions
      if (quantityStr.isNotEmpty && subTotalStr.isNotEmpty && (giftStr.isEmpty || (int.tryParse(giftStr) ?? 0) >= 0)) {
        int invRecQuantity = int.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(quantityStr)) ?? 0;
        double subTotal = double.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(subTotalStr)) ?? 0;
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
          double vatAmount = double.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(
                  record.toJson()[AppConstants.invRecVat].toString())) ??
              0.0;
          int quantity = int.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(
                  record.toJson()[AppConstants.invRecQuantity].toString())) ??
              1;

          return previousValue + (vatAmount * quantity);
        },
      );

  int get computeGiftsTotal {
    mainTableStateManager.setShowLoading(true);

    int total = mainTableStateManager.rows.fold(0, (sum, record) {
      String giftValue = record.toJson()[AppConstants.invRecGift] ?? '';
      if (giftValue.isNotEmpty) {
        int quantity = int.tryParse(AppServiceUtils.replaceArabicNumbersWithEnglish(
                record.toJson()[AppConstants.invRecQuantity].toString())) ??
            0;
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

    if (record.toJson()[AppConstants.invRecGift] != null && record.toJson()[AppConstants.invRecGift] != '') {
      gifts = int.tryParse(
              AppServiceUtils.replaceArabicNumbersWithEnglish(record.toJson()[AppConstants.invRecGift].toString())) ??
          0;
    }
    mainTableStateManager.setShowLoading(false);

    return gifts;
  }

  double computeGiftPrice(record) {
    double itemSubTotal = double.tryParse(record.toJson()[AppConstants.invRecSubTotal].toString())!;
    double itemVAt = double.tryParse(
            AppServiceUtils.replaceArabicNumbersWithEnglish(record.toJson()[AppConstants.invRecVat].toString())) ??
        0;

    return itemSubTotal + itemVAt;
  }

  double computeRecordGiftsTotal(record) {
    int recordGiftsNumber = computeRecordGiftsNumber(record);
    double giftPrice = computeGiftPrice(record);
    return recordGiftsNumber * giftPrice;
  }

  double get computeGifts {
    double total = mainTableStateManager.rows.fold(0.0, (sum, record) {
      if (record.toJson()[AppConstants.invRecSubTotal] != '' && record.toJson()[AppConstants.invRecGift] != '') {
        return sum + computeRecordGiftsTotal(record);
      }
      return sum;
    });

    return total;
  }

  double calculateDiscount(double total, double discountRate) {
    return total * (discountRate / 100);
  }

  double calculateAmountFromRatio(double ratio, total) {
    return total * (ratio / 100);
  }

  double calculateRatioFromAmount(double amount, total) {
    return (amount / total) * 100;
  }

  double calculateFinalTotal(InvoicePlutoUtils invoiceUtils) =>
      computeWithVatTotal - computeDiscounts(invoiceUtils) + computeAdditions(invoiceUtils);

  double computeDiscounts(InvoicePlutoUtils invoiceUtils) {
    double discounts = 0;

    if (additionsDiscountsStateManager.rows.isEmpty) return 0;

    final PlutoRow ratioRow = invoiceUtils.ratioRow;

    final discountRatio = invoiceUtils.getCellValueInDouble(ratioRow.cells, AppConstants.discount);

    if (discountRatio == 0) return 0;

    discounts = computeWithVatTotal * (discountRatio / 100);

    return discounts;
  }

  double computeAdditions(InvoicePlutoUtils invoiceUtils) {
    double additions = 0;

    if (additionsDiscountsStateManager.rows.isEmpty) return 0;

    final PlutoRow ratioRow = invoiceUtils.ratioRow;

    final additionsRatio = invoiceUtils.getCellValueInDouble(ratioRow.cells, AppConstants.addition);

    if (additionsRatio == 0) return 0;

    additions = computeWithVatTotal * (additionsRatio / 100);

    return additions;
  }
}
