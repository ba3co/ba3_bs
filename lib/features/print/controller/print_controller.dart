// lib/features/print/controller/printing_controller.dart

import 'dart:convert' show AsciiCodec;
import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:get/get.dart';

import '../core/print_job.dart';
import '../core/printer_device.dart';
import '../core/print_result.dart';
import '../service/printer_manager.dart';
import '../templates/label_template.dart';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../escpos/escpos_generator.dart';

import '../io/print_adapter.dart';
import '../io/windows_raw_adapter.dart';
import '../io/macos_raw_adapter.dart';

import '../../bill/data/models/invoice_record_model.dart';

// ZPL
import '../zpl/zpl_helpers.dart';

class PrintingController extends GetxController {
  final PrinterManager manager;

  PrintingController(this.manager);

  // ======= فواتير ESC/POS تبقى كما هي =======
  Future<PrintResult> printReceipt58({
    required List<InvoiceRecordModel> items,
    required int billNumber,
    required String date,
    required String seller,
    required String customer,
    required String nots,
  }) async {
    final job = PrintJob(
      billNumber: billNumber,
      invoiceDate: date,
      sellerName: seller,
      customerNumber: customer,
      nots: nots,
      items: items,
    );
    final device = PrinterDevice(
      name: AppConstants.recitePrinter58Name,
      paperKind: PaperKind.mm58,
      platform: GetPlatform.isWindows ? PlatformKind.windows : PlatformKind.macos,
    );
    return manager.printJob(device, job);
  }

  Future<PrintResult> printReceipt80({
    required List<InvoiceRecordModel> items,
    required int billNumber,
    required String date,
    required String seller,
    required String customer,
    required String nots,
  }) async {
    final job = PrintJob(
      billNumber: billNumber,
      invoiceDate: date,
      sellerName: seller,
      customerNumber: customer,
      nots: nots,
      items: items,
    );
    final device = PrinterDevice(
      name: AppConstants.recitePrinter80Name,
      paperKind: PaperKind.mm80,
      platform: GetPlatform.isWindows ? PlatformKind.windows : PlatformKind.macos,
    );
    return manager.printJob(device, job);
  }

  // ======= ليبل ESC/POS لغير Zebra =======
  Future<PrintResult> printLabel({
    required String printerName,
    required String barcodeData,
    String? title,
  }) async {
    final device = PrinterDevice(
      name: printerName,
      paperKind: PaperKind.label,
      platform: GetPlatform.isWindows ? PlatformKind.windows : PlatformKind.macos,
    );

    final profile = await CapabilityProfile.load();
    final generator = EscposGenerator(PaperSize.mm58, profile);

    final labelTemplate = LabelTemplate(data: barcodeData, title: title);
    final bytes = await labelTemplate.build(
      generator,
      const PrintJob(
        nots: '',
        billNumber: 0,
        invoiceDate: '',
        sellerName: '',
        customerNumber: '',
        items: [],
      ),
    );

    final adapter = _adapterFor(device.platform);
    return adapter.send(bytes, printerName: device.name);
  }

  // ======= ليبل ZPL لطابعات Zebra (GX420t, ...) =======
  Future<PrintResult> printTitlePriceBarcodeFullWidth({
    String printerName = AppConstants.labelPrinterName,
    required String barcodeData,
    String? title,
    String? priceText,
    double widthMm = 55,
    double heightMm = 30,
    int copies = 1,
    int darkness = 18,
    int printSpeed = 2,
    double quietZoneMm = 2.0,
  }) async {
    final device = PrinterDevice(
      name: printerName,
      paperKind: PaperKind.label,
      platform: GetPlatform.isWindows ? PlatformKind.windows : PlatformKind.macos,
    );

    final zpl = buildTitlePriceBarcodeFullWidthZpl(
        data: barcodeData,
        title: title,
        priceText: priceText,
        labelWidthMm: widthMm,
        labelHeightMm: heightMm,
        copies: copies,
        darkness: darkness,
        printSpeed: printSpeed,
        quietZoneMm: quietZoneMm,
        barcodeHeight: 80,
        titleFontHeight: 20,
        marginTopDots: 15,
        titleLineSpacing: 2
        // باقي الإعدادات الافتراضية داخل الدالة
        );

    final adapter = _adapterFor(device.platform);
    final bytes = const AsciiCodec(allowInvalid: true).encode(zpl);
    return adapter.send(bytes, printerName: device.name);
  }

  // Helpers
  PrintAdapter _adapterFor(PlatformKind platform) {
    return platform == PlatformKind.windows ? WindowsRawAdapter() : MacosRawAdapter();
  }
  /// 203dpi ≈ 8 dots لكل 1mm
  int mmToDots(num mm) => (mm * 8).round();

  Future<void> zebraCalibrateAndSetup({
    required String printerName,
    required int widthDots,    // مثال: 50mm => 400
    required int heightDots,   // مثال: 30mm => 240
    int darkness = 18,
    int speed = 2,
    ZebraMedia media = ZebraMedia.gap, // Gap/Web الافتراضي
    bool saveToMemory = false,         // ^JUS حفظ الإعدادات
  }) async {
    // Media Tracking: ^MTT (Gap), ^MTR (Mark), ^MTN (Continuous)
    final mt = switch (media) {
      ZebraMedia.gap        => '^MTT',
      ZebraMedia.mark       => '^MTR',
      ZebraMedia.continuous => '^MTN',
    };

    // 🔒 لا تضع أي تعليقات داخل ZPL. ASCII فقط.
    final zpl = '''
^XA
$mt
^MMT
^PW$widthDots
^LL$heightDots
^LS0
^LT0
^PR$speed
^MD$darkness
~JC
${saveToMemory ? '^JUS' : ''}
^XZ
''';

    // ASCII-safe
    final bytes = const AsciiCodec(allowInvalid: true).encode(zpl);

    // Standalone adapter (بدون الاعتماد على _adapterFor)
    final PrintAdapter adapter = GetPlatform.isWindows
        ? WindowsRawAdapter()
        : MacosRawAdapter();

    await adapter.send(bytes, printerName: printerName);
  }

}
enum ZebraMedia { gap, mark, continuous }