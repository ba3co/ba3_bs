import 'dart:async';

import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../invoice/data/models/invoice_record_model.dart';
import '../ui/widgets/printing_loading_dialog.dart';

class PrintingController extends GetxController with GetSingleTickerProviderStateMixin {
  bool connected = false;
  List<BluetoothInfo> items = [];

  late final AnimationController animationController;
  var dots = ''.obs;
  Timer? _dotTimer;

  @override
  void onInit() {
    super.onInit();
    _startDotAnimation(); // Start the dot animation
  }

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      dots.value = dots.value.length < 3 ? '${dots.value}.' : ''; // Cycle dots
    });
  }

  Future<void> startPrinting({
    required List<InvoiceRecordModel> invRecords,
    required String invId,
    required String invDate,
  }) async {
    Get.defaultDialog(content: const PrintingLoadingDialog());
    await printInvoice(invRecords: invRecords, invId: invId, invDate: invDate);
    Get.back();
  }

  @override
  void onClose() {
    _dotTimer?.cancel(); // Cancel the timer on close
    super.onClose();
  }

  Future<void> printInvoice(
      {required List<InvoiceRecordModel> invRecords, required String invId, required String invDate}) async {
    List<BluetoothInfo> allBluetooth = await getBluetoothDevices();

    const macAddress = '66:32:8D:F3:FF:7E';
    if (allBluetooth.any((e) => e.macAdress.toLowerCase() == macAddress.toLowerCase())) {
      if (!connected) {
        await connectToPrinter(macAddress);
      }
      await sendPrintData(invRecords, invDate, invId);
    } else {
      debugPrint('Cannot find the printer');
    }
  }

  Future<List<BluetoothInfo>> getBluetoothDevices() async {
    items = await PrintBluetoothThermal.pairedBluetooths;
    debugPrint('isPermissionBluetoothGranted ${await PrintBluetoothThermal.isPermissionBluetoothGranted}');
    return items;
  }

  Future<void> connectToPrinter(String mac) async {
    connected = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    debugPrint('Connection status: $connected');
  }

  Future<void> disconnectPrinter() async {
    connected = !(await PrintBluetoothThermal.disconnect);
    debugPrint('Disconnect status: $connected');
  }

  Future<void> sendPrintData(List<InvoiceRecordModel> invRecords, String invDate, String invId) async {
    if (await PrintBluetoothThermal.connectionStatus) {
      List<int> ticket = await generateInvoicePrintData(invRecords, invDate, invId);
      bool result = await PrintBluetoothThermal.writeBytes(ticket);
      debugPrint('Print result: $result');
    } else {
      await disconnectPrinter();
      debugPrint('Print connection status: false');
    }
  }

  Future<List<int>> generateInvoicePrintData(
    List<InvoiceRecordModel> invoiceRecords,
    String invoiceDate,
    String invoiceId,
  ) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = generator.reset();

    bytes += generator.text('Tax Invoice', styles: const PosStyles(align: PosAlign.center), linesAfter: 1);
    bytes += await _generateLogo(generator);
    bytes += _generateHeader(generator, invoiceDate, invoiceId);

    double totalAmount = 0;
    double netAmount = 0;
    double vatAmount = 0;

    var materialController = Get.find<MaterialController>();
    for (InvoiceRecordModel record in invoiceRecords) {
      final materialModel = materialController.getMaterialFromId(record.invRecId!);
      final lineData = _calculateLineTotals(record);

      totalAmount += lineData['lineTotal']!;
      netAmount += lineData['netTotal']!;
      vatAmount += lineData['vatTotal']!;

      bytes += _generateItemDetails(generator, materialModel, record, lineData);
    }

    bytes += _generateTotalSummary(generator, netAmount, vatAmount);
    bytes += _generateFooter(generator);

    debugPrint('totalAmount $totalAmount');

    return bytes;
  }

  Future<List<int>> _generateLogo(Generator generator) async {
    final ByteData data = await rootBundle.load('assets/images/ba3_logo.jpg');
    final Uint8List imageBytes = data.buffer.asUint8List();
    final img.Image? image = img.decodeImage(imageBytes);
    return image != null ? generator.imageRaster(image) : [];
  }

  List<int> _generateHeader(Generator generator, String date, String invoiceId) {
    return [
      ...generator.text('Burj AlArab Mobile Phone', styles: const PosStyles(align: PosAlign.center, bold: true)),
      ...generator.text('Date: $date', styles: const PosStyles(align: PosAlign.left)),
      ...generator.text('IN NO: $invoiceId', styles: const PosStyles(align: PosAlign.left)),
      ...generator.text('TRN: 10036 93114 00003', styles: const PosStyles(align: PosAlign.left), linesAfter: 1),
    ];
  }

  Map<String, double> _calculateLineTotals(InvoiceRecordModel record) {
    double unitPriceWithVat = record.invRecTotal! / record.invRecQuantity!;
    double vatPerUnit = unitPriceWithVat - (unitPriceWithVat / 1.05);
    double netPerUnit = unitPriceWithVat / 1.05;
    return {
      'unitPriceWithVat': unitPriceWithVat,
      'vatPerUnit': vatPerUnit,
      'netPerUnit': netPerUnit,
      'lineTotal': record.invRecTotal!,
      'netTotal': record.invRecQuantity! * netPerUnit,
      'vatTotal': record.invRecQuantity! * vatPerUnit,
    };
  }

  List<int> _generateItemDetails(
    Generator generator,
    MaterialModel material,
    InvoiceRecordModel record,
    Map<String, double> lineData,
  ) {
    return [
      ...generator.text(
        material.matName?.substring(0, material.matName!.length.clamp(0, 64)) ?? '',
        styles: const PosStyles(align: PosAlign.left),
      ),
      ...generator.text(material.matBarCode ?? '', styles: const PosStyles(align: PosAlign.left)),
      ...generator.text(
        '${record.invRecQuantity} X ${lineData['unitPriceWithVat']!.toStringAsFixed(2)} -> '
        'Total: ${lineData['lineTotal']!.toStringAsFixed(2)}',
        styles: const PosStyles(align: PosAlign.left),
        linesAfter: 1,
      ),
    ];
  }

  List<int> _generateTotalSummary(Generator generator, double netTotal, double vatTotal) {
    return [
      ...generator.text('Total VAT: ${vatTotal.toStringAsFixed(2)}', styles: const PosStyles(align: PosAlign.center)),
      ...generator.text('-' * 30, styles: const PosStyles(align: PosAlign.right)),
      ...generator.text('Sub: ${netTotal.toStringAsFixed(2)} AED',
          styles: const PosStyles(align: PosAlign.right, bold: true)),
      ...generator.text('VAT: ${vatTotal.toStringAsFixed(2)} AED',
          styles: const PosStyles(align: PosAlign.right, bold: true)),
      ...generator.text('Total: ${(netTotal + vatTotal).toStringAsFixed(2)} AED',
          styles: const PosStyles(align: PosAlign.right, bold: true)),
    ];
  }

  List<int> _generateFooter(Generator generator) {
    return [
      ...generator.text('UAE, Rak, Sadaf Roundabout', styles: const PosStyles(align: PosAlign.center)),
      ...generator.text('+971568666411', styles: const PosStyles(align: PosAlign.center)),
      ...generator.text('Thanks For Visiting BA3', styles: const PosStyles(align: PosAlign.center, bold: true)),
      ...generator.feed(2),
    ];
  }
}
