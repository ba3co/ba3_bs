import 'dart:async';

import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../core/services/translation/implementations/translation_repository.dart';
import '../../../core/styling/printer_text_styles.dart';
import '../../invoice/data/models/invoice_record_model.dart';
import '../../materials/data/models/material_model.dart';
import '../ui/widgets/printing_loading_dialog.dart';

class PrintingController extends GetxController {
  final TranslationRepository _translationRepository;

  PrintingController(this._translationRepository);

  bool connected = false;
  List<BluetoothInfo> items = [];

  var dots = ''.obs;
  Timer? _dotTimer;

  @override
  void onInit() {
    super.onInit();
    _startDotAnimation();
  }

  void _startDotAnimation() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      dots.value = dots.value.length < 3 ? '${dots.value}.' : '';
    });
  }

  Future<void> startPrinting(
      {required List<InvoiceRecordModel> invRecords, required String invId, required String invDate}) async {
    Get.defaultDialog(
      title: '',
      content: const PrintingLoadingDialog(),
      contentPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      radius: 8,
    );

    await printInvoice(invRecords: invRecords, invId: invId, invDate: invDate);
    Get.back();
    Get.delete<PrintingController>();
  }

  @override
  void onClose() {
    _dotTimer?.cancel();
    super.onClose();
  }

  Future<void> printInvoice(
      {required List<InvoiceRecordModel> invRecords, required String invId, required String invDate}) async {
    List<BluetoothInfo> pairedDevices = await getBluetoothDevices();
    const String printerMacAddress = ApiConstants.printerMacAddress;

    // Check if the specified printer is among the paired devices
    bool printerFound =
        pairedDevices.any((device) => device.macAdress.toLowerCase() == printerMacAddress.toLowerCase());

    if (printerFound) {
      if (!connected) await connectToPrinter(printerMacAddress);

      await sendPrintData(invRecords, invDate, invId);
    } else {
      debugPrint('Cannot find the printer');
    }
  }

  // Retrieves a list of paired Bluetooth devices
  Future<List<BluetoothInfo>> getBluetoothDevices() async {
    items = await PrintBluetoothThermal.pairedBluetooths;
    debugPrint('isPermissionBluetoothGranted ${await PrintBluetoothThermal.isPermissionBluetoothGranted}');
    return items;
  }

  // Connects to the printer using its MAC address
  Future<void> connectToPrinter(String mac) async {
    connected = await PrintBluetoothThermal.connect(macPrinterAddress: mac);
    debugPrint('Connection status: $connected');
  }

  // Disconnects from the printer
  Future<void> disconnectPrinter() async {
    connected = !(await PrintBluetoothThermal.disconnect);
    debugPrint('Disconnect status: $connected');
  }

  // Sends the print data to the printer if connected
  Future<void> sendPrintData(List<InvoiceRecordModel> invRecords, String invDate, String invId) async {
    if (await PrintBluetoothThermal.connectionStatus) {
      List<int> ticket = await generateInvoicePrintData(invRecords, invDate, invId);

      // Write bytes to the printer
      await PrintBluetoothThermal.writeBytes(ticket);
    } else {
      await disconnectPrinter();
      debugPrint('Print connection status: false');
    }
  }

  // Generates the print data for the invoice
  Future<List<int>> generateInvoicePrintData(
      List<InvoiceRecordModel> invoiceRecords, String invoiceDate, String invoiceId) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = generator.reset();

    // Header
    bytes += generator.text('Tax Invoice', styles: PrinterTextStyles.centered, linesAfter: 1);
    bytes += await _generateLogo(generator);
    bytes += _generateHeader(generator, invoiceDate, invoiceId);

    // Process Items
    final result = await _processInvoiceItems(generator, invoiceRecords);
    bytes += result.bytes;

    // Totals Summary
    bytes += _generateTotalSummary(generator, result.totals['netAmount']!, result.totals['vatAmount']!);

    // Footer
    bytes += _generateFooter(generator);

    return bytes;
  }

// Processes each invoice record, calculates totals, and adds item details to the print data
  Future<({List<int> bytes, Map<String, double> totals})> _processInvoiceItems(
      Generator generator, List<InvoiceRecordModel> invoiceRecords) async {
    double netAmount = 0;
    double vatAmount = 0;
    List<int> itemBytes = [];

    final materialController = Get.find<MaterialController>();

    for (var record in invoiceRecords) {
      final material = materialController.getMaterialById(record.invRecId!);
      final recordTotals = _calculateInvoiceRecordTotals(record);

      // Update totals
      netAmount += recordTotals['netTotal']!;
      vatAmount += recordTotals['vatTotal']!;

      // Generate item details
      itemBytes += await _generateItemDetails(generator, material, record, recordTotals);
    }

    return (bytes: itemBytes, totals: {'netAmount': netAmount, 'vatAmount': vatAmount});
  }

// Calculates totals for an invoice record
  Map<String, double> _calculateInvoiceRecordTotals(InvoiceRecordModel record) {
    final unitPriceWithVat = record.invRecTotal! / record.invRecQuantity!;
    final vatPerUnit = unitPriceWithVat * 0.05;
    final netPerUnit = unitPriceWithVat - vatPerUnit;

    return {
      'unitPriceWithVat': unitPriceWithVat,
      'vatPerUnit': vatPerUnit,
      'netPerUnit': netPerUnit,
      'lineTotal': record.invRecTotal!,
      'netTotal': record.invRecQuantity! * netPerUnit,
      'vatTotal': record.invRecQuantity! * vatPerUnit,
    };
  }

// Generates the item details for each invoice record
  Future<List<int>> _generateItemDetails(
      Generator generator, MaterialModel material, InvoiceRecordModel record, Map<String, double> totals) async {
    final itemName = (material.matName ?? '').substring(0, (material.matName?.length ?? 0).clamp(0, 64));
    final translatedName = await _translationRepository.translateText(itemName);

    return [
      ...generator.text(translatedName, styles: PrinterTextStyles.left),
      ...generator.text(material.matBarCode ?? '', styles: PrinterTextStyles.left),
      ...generator.text(
        '${record.invRecQuantity} x ${totals['unitPriceWithVat']!.toStringAsFixed(2)} -> '
        'Total: ${totals['lineTotal']!.toStringAsFixed(2)}',
        styles: PrinterTextStyles.left,
        linesAfter: 1,
      ),
    ];
  }

  // Generates the logo image for printing
  Future<List<int>> _generateLogo(Generator generator) async {
    try {
      final ByteData data = await rootBundle.load('assets/images/ba3_logo.jpg');
      final Uint8List imageBytes = data.buffer.asUint8List();
      final img.Image? image = img.decodeImage(imageBytes);

      if (image != null) {
        final img.Image resizedImage = img.copyResize(image, width: 200);
        return generator.imageRaster(resizedImage);
      } else {
        debugPrint('Failed to decode the image');
      }
    } catch (e) {
      debugPrint('Error generating logo: $e');
    }
    return [];
  }

  List<int> _generateHeader(Generator generator, String date, String invoiceId) {
    return [
      ...generator.emptyLines(2),
      ...generator.text('Burj AlArab Mobile Phone', styles: PrinterTextStyles.boldCentered),
      ...generator.emptyLines(1),
      ...generator.text('Date: $date', styles: PrinterTextStyles.left),
      ...generator.text('IN NO: $invoiceId', styles: PrinterTextStyles.left),
      ...generator.text('TRN: 10036 93114 00003', styles: PrinterTextStyles.left, linesAfter: 1),
    ];
  }

  List<int> _generateTotalSummary(Generator generator, double netTotal, double vatTotal) {
    return [
      ...generator.text('Total VAT: ${vatTotal.toStringAsFixed(2)}', styles: PrinterTextStyles.centered),
      ...generator.text('-' * 30, styles: PrinterTextStyles.right),
      ...generator.text('Sub: ${netTotal.toStringAsFixed(2)} AED', styles: PrinterTextStyles.rightBold),
      ...generator.text('VAT: ${vatTotal.toStringAsFixed(2)} AED', styles: PrinterTextStyles.rightBold),
      ...generator.text('Total: ${(netTotal + vatTotal).toStringAsFixed(2)} AED', styles: PrinterTextStyles.rightBold),
      ...generator.emptyLines(1),
    ];
  }

  List<int> _generateFooter(Generator generator) {
    return [
      ...generator.text('UAE, Rak, Sadaf Roundabout', styles: PrinterTextStyles.centered),
      ...generator.text('+971568666411', styles: PrinterTextStyles.centered),
      ...generator.text('Thanks For Visiting BA3', styles: PrinterTextStyles.boldCentered),
      ...generator.emptyLines(2),
    ];
  }
}
