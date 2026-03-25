import 'dart:async';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/dialogs/custom_alert_dialog/models/custom_alert_type.dart';
import 'package:ba3_bs/core/dialogs/custom_alert_dialog/widgets/custom_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/receipt_print_brand.dart';

/// Same overlay style as [HelperAlert] / [CustomAlertDialog]; Enter and Space
/// select the default (mobile) shop.
final class ReceiptPrintBrandDialog {
  ReceiptPrintBrandDialog._();

  static Future<ReceiptPrintBrand?> show() async {
    final completer = Completer<ReceiptPrintBrand?>();
    void complete(ReceiptPrintBrand? value) {
      if (!completer.isCompleted) completer.complete(value);
    }

    CustomAlertDialog.show(
      type: CustomAlertType.confirm,
      title: 'اختر المحل للطباعة',
      text: 'إنتر أو مسافة — المحل الأساسي (الجوالات)',
      confirmBtnText: 'Burj Al Arab Mobile Phones',
      cancelBtnText: 'Al Burj BA3 — السيارات',
      barrierDismissible: false,
      confirmOnSpace: true,
      widget: ExcludeFocus(
        child: TextButton(
          onPressed: () {
            CustomAlertDialog.hide();
            complete(null);
          },
          child: Text(AppStrings.cancel.tr),
        ),
      ),
      onConfirmBtnTap: () => complete(ReceiptPrintBrand.mobilePhones),
      onCancelBtnTap: () => complete(ReceiptPrintBrand.carAccessories),
    );

    return completer.future;
  }
}
