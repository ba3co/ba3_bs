import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../invoice/data/models/invoice_record_model.dart';

class PrintController extends GetxController {
  Future<void> printFunction(
      {required List<InvoiceRecordModel> invRecords, required String invDate, required String invId}) async {
    List<BluetoothInfo> allBluetooth = await getBluetooth();

    if (allBluetooth.map((e) => e.macAdress).toList().contains('66:32:8D:F3:FF:7E')) {
      if (!connected) {
        await connect('66:32:8D:F3:FF:7E');
      }

      await printTest(invRecords, invDate, invId);

      //await disconnect();
    } else if (allBluetooth.map((e) => e.macAdress).toList().contains('66:32:8d:f3:ff:7e')) {
      if (!connected) {
        await connect('66:32:8d:f3:ff:7e');
      }

      await printTest(invRecords, invDate, invId);

      //await disconnect();
    } else {
      debugPrint('Cant find the printer');
    }
  }

  bool connected = false;

  List<BluetoothInfo> items = [];

  Future<List<BluetoothInfo>> getBluetooth() async {
    items = [];

    final List<BluetoothInfo> listResult = await PrintBluetoothThermal.pairedBluetooths;

    debugPrint('isPermissionBluetoothGranted ${await PrintBluetoothThermal.isPermissionBluetoothGranted}');

    items = listResult;

    return items;
  }

  Future<void> connect(String mac) async {
    connected = false;
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    debugPrint('state connect $result');
    if (result) connected = true;
  }

  Future<void> disconnect() async {
    final bool status = await PrintBluetoothThermal.disconnect;

    connected = false;

    debugPrint('status disconnect $status');
  }

  Future<void> printTest(List<InvoiceRecordModel> invRecords, String invDate, String invId) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;

    if (connectionStatus) {
      bool result = false;

      List<int> ticket = await invoicePrint(invRecords, invDate, invId);
      result = await PrintBluetoothThermal.writeBytes(ticket);

      debugPrint('print test result:  $result');
    } else {
      disconnect();
      debugPrint('print test connectionStatus: $connectionStatus');
    }
  }

  Future<List<int>> testImage() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    bytes += generator.feed(2);
    return bytes;
  }

  Future<List<int>> invoicePrint(List<InvoiceRecordModel> invRecords, String invDate, String invId) async {
    List<int> bytes = [];
    // Using default profile
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    //bytes += generator.setGlobalFont(PosFontType.fontA);
    bytes += generator.reset();

    bytes += generator.text('Tax Invoice', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);

    final ByteData data = await rootBundle.load('assets/logo.jpg');
    final Uint8List bytesImg = data.buffer.asUint8List();
    img.Image? image = img.decodeImage(bytesImg);
    bytes += generator.imageRaster(image!);

    bytes += generator.text('Burj AlArab Mobile Phone', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Date: $invDate', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('IN NO: $invId', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('TRN: 10036 93114 00003', styles: const PosStyles(align: PosAlign.left), linesAfter: 1);
    double total = 0;
    double natTotal = 0;
    double vatTotal = 0;

    var materialController = Get.find<MaterialController>();
    for (InvoiceRecordModel model in invRecords) {
      double modelSubTotalWithVat = model.invRecTotal! / model.invRecQuantity!;
      double modelSubVatTotal = modelSubTotalWithVat - (modelSubTotalWithVat / 1.05);
      double modelSubTotal = modelSubTotalWithVat / 1.05;

      MaterialModel materialModel = materialController.getMaterialFromId(model.invRecId!);

      String text = materialModel.matName ?? '';

      // if (text == '') {
      //   await setEnglishNameForProduct(
      //       productModel..prodEngName = await checkArabicWithTranslate(productModel.prodName!));
      //   text = await checkArabicWithTranslate(productModel.prodName!);
      // }

      bytes += generator.text(text.length < 64 ? text : text.substring(0, 64),
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(materialModel.matBarCode ?? "", styles: const PosStyles(align: PosAlign.left));
      double totalOfLine = model.invRecTotal!;
      total = totalOfLine + total;
      // natTotal = model.invRecQuantity!* (model.invRecSubTotal!) +natTotal;
      // vatTotal = model.invRecQuantity!* (model.invRecSubTotal!)*0.05 +vatTotal;
      natTotal = model.invRecQuantity! * modelSubTotal + natTotal;
      vatTotal = model.invRecQuantity! * modelSubVatTotal + vatTotal;
      bytes += generator.text(
          '${model.invRecQuantity} X ${modelSubTotalWithVat.toStringAsFixed(2)} -> Total:${totalOfLine.toStringAsFixed(2)}',
          styles: const PosStyles(align: PosAlign.left),
          linesAfter: 1);
    }

    bytes +=
        generator.text('Total VAT: ${vatTotal.toStringAsFixed(2)}', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('-' * 30, styles: const PosStyles(align: PosAlign.right));
    bytes += generator.text('Sub: ${natTotal.toStringAsFixed(2)} AED',
        styles: const PosStyles(align: PosAlign.right, bold: true));
    bytes += generator.text('VAT: ${vatTotal.toStringAsFixed(2)} AED',
        styles: const PosStyles(align: PosAlign.right, bold: true));
    bytes += generator.text('Total: ${(natTotal + vatTotal).toStringAsFixed(2)} AED',
        styles: const PosStyles(align: PosAlign.right, bold: true));
    bytes += generator.text('UAE, Rak, Sadaf Roundabout', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('+971568666411', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Thanks For Visiting BA3', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.feed(2);
    return bytes;
  }

  Future<List<int>> testTextWarranty(List<InvoiceRecordModel> invRecords, String invDate, String invId) async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    bytes += generator.reset();
    bytes += generator.text('Warranty Invoice', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    bytes += generator.text('Burj AlArab Mobile Phone', styles: const PosStyles(align: PosAlign.center, bold: true));
    bytes += generator.text('Date: $invDate', styles: const PosStyles(align: PosAlign.left));
    bytes += generator.text('IN NO: $invId', styles: const PosStyles(align: PosAlign.left));

    var materialController = Get.find<MaterialController>();
    for (InvoiceRecordModel model in invRecords) {
      MaterialModel materialModel = materialController.getMaterialFromId(model.invRecId!);
      String text = materialModel.matName ?? '';

      // if (text == '') {
      //   await setEnglishNameForProduct(
      //       materialModel..prodEngName = await checkArabicWithTranslate(materialModel.prodName!));
      //   text = await checkArabicWithTranslate(materialModel.prodName!);
      // }

      bytes += generator.text(text.length < 64 ? text : text.substring(0, 64),
          styles: const PosStyles(align: PosAlign.left));
      bytes += generator.text(materialModel.matBarCode ?? "", styles: const PosStyles(align: PosAlign.left));
    }

    bytes += generator.text('-' * 30, styles: const PosStyles(align: PosAlign.right));

    bytes += generator.text('UAE, Rak, Sadaf Roundabout', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('0568666411', styles: const PosStyles(align: PosAlign.center));
    bytes += generator.text('Thanks For Visiting BA3', styles: const PosStyles(align: PosAlign.center, bold: true));

    bytes += generator.feed(2);

    return bytes;
  }

  double computeWithoutVatTotal(records) {
    int quantity = 0;
    double subtotals = 0.0;
    double total = 0.0;
    for (var record in records) {
      if (record.invRecQuantity != null && record.invRecSubTotal != null) {
        quantity = record.invRecQuantity!;
        subtotals = record.invRecSubTotal!;
        total += quantity * (subtotals);
      }
    }
    return total;
  }

  double computeAllTotal(records) {
    int quantity = 0;
    double subtotals = 0.0;
    double total = 0.0;
    for (var record in records) {
      if (record.invRecQuantity != null && record.invRecSubTotal != null) {
        quantity = record.invRecQuantity!;
        subtotals = record.invRecSubTotal!;
        total += quantity * (subtotals + record.invRecVat!);
      }
    }
    return total;
  }

  double computeVatTotal(records) {
    int quantity = 0;
    double total = 0.0;
    for (var record in records) {
      if (record.invRecQuantity != null && record.invRecSubTotal != null) {
        quantity = record.invRecQuantity!;
        total += quantity * record.invRecVat!;
      }
    }
    return total;
  }
}
