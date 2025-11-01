// lib/features/print/controller/printing_controller.dart

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ba3_bs/core/constants/app_assets.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:win32/win32.dart' as win32;

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/translation/implementations/translation_repo.dart';
import '../../../core/styling/printer_text_styles.dart';
import '../../bill/data/models/invoice_record_model.dart';
import '../../materials/data/models/materials/material_model.dart';
import '../ui/widgets/printing_loading_dialog.dart';

class PrintingController extends GetxController {
  final TranslationRepository _translationRepository;

  PrintingController(this._translationRepository);

  RxString loadingDots = ''.obs;
  Timer? _loadingAnimationTimer;

  @override
  void onInit() {
    super.onInit();
    _startLoadingDotsAnimation();
  }

  @override
  void onClose() {
    _loadingAnimationTimer?.cancel();
    super.onClose();
  }

  void _startLoadingDotsAnimation() {
    _loadingAnimationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      loadingDots.value = loadingDots.value.length < 3 ? '${loadingDots.value}.' : '';
    });
  }

  Future<void> startPrinting({
    required BuildContext context,
    required int billNumber,
    required List<InvoiceRecordModel> invRecords,
    required String invDate,
    required String sellerName,
    required String customerNumber,
  }) async {
    _showLoadingDialog(context);
    try {
      final translatedSellerName = await _translationRepository.translateText(sellerName);

      final bytes = await _generateBillPrintData(invRecords, invDate, translatedSellerName,customerNumber,billNumber,);

      if (!kIsWeb && Platform.isWindows) {
        await _sendTicketWindowsRaw(bytes, printerName: PrinterConstants.printerNameWindows);
      } else if (!kIsWeb && Platform.isMacOS) {
        await _sendTicketMacRaw(bytes, printerName: PrinterConstants.printerNameMac);
      } else {
        log('Unsupported platform for USB RAW printing.');
        Get.snackbar('Printing', 'Unsupported platform for USB RAW printing');
      }
    } finally {
      _dismissLoadingDialog();
    }
  }

  void _showLoadingDialog(BuildContext context) {
    OverlayService.showDialog(
      context: context,
      title: '',
      width: 250,
      height: 100,
      content: const PrintingLoadingDialog(),
      contentPadding: EdgeInsets.zero,
      onCloseCallback: () => Get.delete<PrintingController>(),
    );
  }

  void _dismissLoadingDialog() => OverlayService.back();

  // ----------------------------
  // WINDOWS: RAW via Win32
  // ----------------------------
  Future<void> _sendTicketWindowsRaw(
      List<int> ticket, {
        required String printerName,
      }) async {
    try {
      final data = Uint8List.fromList(ticket);

      final printerNamePtr = printerName.toNativeUtf16();
      final pHandle = calloc<ffi.IntPtr>();
      final pDefaults = calloc<win32.PRINTER_DEFAULTS>();
      pDefaults.ref
        ..pDatatype = win32.TEXT('RAW')
        ..pDevMode = ffi.nullptr
        ..DesiredAccess = win32.PRINTER_ACCESS_USE;

      final opened = win32.OpenPrinter(printerNamePtr, pHandle, pDefaults);
      if (opened == 0) {
        log('OpenPrinter failed. GetLastError=${win32.GetLastError()}');
        calloc
          ..free(printerNamePtr)
          ..free(pHandle)
          ..free(pDefaults);
        return;
      }

      final docInfo = calloc<win32.DOC_INFO_1>();
      docInfo.ref
        ..pDocName = win32.TEXT('ESC/POS from Flutter')
        ..pOutputFile = ffi.nullptr
        ..pDatatype = win32.TEXT('RAW');

      final docId = win32.StartDocPrinter(pHandle.value, 1, docInfo);
      if (docId <= 0) {
        log('StartDocPrinter failed. GetLastError=${win32.GetLastError()}');
        win32.EndDocPrinter(pHandle.value);
        win32.ClosePrinter(pHandle.value);
        calloc
          ..free(printerNamePtr)
          ..free(pHandle)
          ..free(pDefaults)
          ..free(docInfo);
        return;
      }

      if (win32.StartPagePrinter(pHandle.value) == 0) {
        log('StartPagePrinter failed. GetLastError=${win32.GetLastError()}');
        win32.EndDocPrinter(pHandle.value);
        win32.ClosePrinter(pHandle.value);
        calloc
          ..free(printerNamePtr)
          ..free(pHandle)
          ..free(pDefaults)
          ..free(docInfo);
        return;
      }

      final dataPtr = calloc<ffi.Uint8>(data.length);
      dataPtr.asTypedList(data.length).setAll(0, data);
      final written = calloc<ffi.Uint32>();

      final ok = win32.WritePrinter(pHandle.value, dataPtr, data.length, written);
      if (ok == 0) {
        log('WritePrinter failed. GetLastError=${win32.GetLastError()}');
      } else {
        log('Wrote ${written.value} bytes to printer');
      }

      win32.EndPagePrinter(pHandle.value);
      win32.EndDocPrinter(pHandle.value);
      win32.ClosePrinter(pHandle.value);

      calloc
        ..free(printerNamePtr)
        ..free(pHandle)
        ..free(pDefaults)
        ..free(docInfo)
        ..free(dataPtr)
        ..free(written);
    } catch (e) {
      log('Exception in _sendTicketWindowsRaw: $e');
    }
  }

  // ----------------------------
  // macOS: RAW via stdin (بدون lpstat) + fallbacks
  // ----------------------------
  // macOS: اطبع RAW عبر ملف مؤقت + Process.run (بدون detached)
// macOS: اطبع RAW عبر stdin بدون ملفات مؤقتة، مع محاولة تعيين POS80 كافتراضي إذا لزم
  Future<void> _sendTicketMacRaw(
      List<int> ticket, {
        required String printerName,
      }) async {
    try {
      // محاولة 1: lp -d <printer> -o raw  عبر stdin
      {
        final p = await Process.start(
          '/usr/bin/lp',
          ['-d', printerName, '-o', 'raw'],
          // مهم: الوضع الافتراضي (ليس detachedWithStdio)
        );
        p.stdin.add(ticket);
        await p.stdin.flush();
        await p.stdin.close();
        final code = await p.exitCode;
        final out = await p.stdout.transform(const Utf8Decoder()).join();
        final err = await p.stderr.transform(const Utf8Decoder()).join();
        log('lp (stdin) -> $printerName  stdout: $out');
        log('lp (stdin) -> $printerName  stderr: $err');
        if (code == 0) return;
      }

      // محاولة 2: اضبط الطابعة الافتراضية POS80 برمجياً ثم lp -o raw عبر stdin
          {
        final setDef = await Process.run('/usr/bin/lpoptions', ['-d', printerName]);
        log('lpoptions set default stdout: ${setDef.stdout}');
        log('lpoptions set default stderr: ${setDef.stderr}');
        // حتى لو فشل، نجرب على أي حال
        final p = await Process.start(
          '/usr/bin/lp',
          ['-o', 'raw'],
        );
        p.stdin.add(ticket);
        await p.stdin.flush();
        await p.stdin.close();
        final code = await p.exitCode;
        final out = await p.stdout.transform(const Utf8Decoder()).join();
        final err = await p.stderr.transform(const Utf8Decoder()).join();
        log('lp (stdin, default) stdout: $out');
        log('lp (stdin, default) stderr: $err');
        if (code == 0) return;
      }

      // محاولة 3: lpr -P <printer> -l  عبر stdin
          {
        final p2 = await Process.start(
          '/usr/bin/lpr',
          ['-P', printerName, '-l'],
        );
        p2.stdin.add(ticket);
        await p2.stdin.flush();
        await p2.stdin.close();
        final code2 = await p2.exitCode;
        final out2 = await p2.stdout.transform(const Utf8Decoder()).join();
        final err2 = await p2.stderr.transform(const Utf8Decoder()).join();
        log('lpr -> $printerName  stdout: $out2');
        log('lpr -> $printerName  stderr: $err2');
        if (code2 == 0) return;
      }

      // محاولة 4: lpr -l (على الافتراضي)
          {
        final p3 = await Process.start(
          '/usr/bin/lpr',
          ['-l'],
        );
        p3.stdin.add(ticket);
        await p3.stdin.flush();
        await p3.stdin.close();
        final code3 = await p3.exitCode;
        final out3 = await p3.stdout.transform(const Utf8Decoder()).join();
        final err3 = await p3.stderr.transform(const Utf8Decoder()).join();
        log('lpr (default) stdout: $out3');
        log('lpr (default) stderr: $err3');
        if (code3 != 0) {
          throw Exception('macOS print failed (lpr default) code=$code3');
        }
      }
    } catch (e) {
      log('Exception in _sendTicketMacRaw: $e');
    }
  }



  // ----------------------------
  // توليد بايتات الفاتورة (قوائم growable فقط)
  // ----------------------------
  Future<List<int>> _generateBillPrintData(
      List<InvoiceRecordModel> invoiceRecords,
      String invoiceDate,
      String sellerName,
      String customerNumber,
      int billNumber,
      ) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PrinterConstants.paperSize, profile);

    final bytes = <int>[];

    // Header
    bytes.addAll(generator.reset());
    bytes.addAll(generator.text(
      PrinterConstants.invoiceTitle,
      styles: PrinterTextStyles.centered,
      linesAfter: 1,
    ));
    bytes.addAll(await _generateLogo(generator));
    bytes.addAll(_createHeaderSection(generator, invoiceDate, billNumber,sellerName,customerNumber));

    // Items
    final result = await _generateItemsDetailsAndTotals(generator, invoiceRecords);
    bytes.addAll(result.bytes);

    // Totals
    bytes.addAll(_generateTotalSummary(
      generator,
      result.totals['netAmount']!,
      result.totals['vatAmount']!,
    ));

    // Footer
    bytes.addAll(_createFooterSection(generator));

    // اختياري: قصّ الورق
    bytes.addAll(generator.cut());

    return bytes;
  }

  Future<({List<int> bytes, Map<String, double> totals})>
  _generateItemsDetailsAndTotals(
      Generator generator,
      List<InvoiceRecordModel> invoiceRecords,
      ) async {
    double netAmount = 0;
    double vatAmount = 0;
    final itemBytes = <int>[];

    final materialController = read<MaterialController>();

    for (final record in invoiceRecords) {
      final material = materialController.getMaterialById(record.invRecId!);
      final recordTotals = _computeRecordTotals(record);

      netAmount += recordTotals['netTotal']!;
      vatAmount += recordTotals['vatTotal']!;

      itemBytes.addAll(await _generateItemDetails(generator, material, record, recordTotals));
    }

    return (bytes: itemBytes, totals: {'netAmount': netAmount, 'vatAmount': vatAmount});
  }

  Map<String, double> _computeRecordTotals(InvoiceRecordModel record) {
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

  Future<List<int>> _generateItemDetails(
      Generator generator,
      MaterialModel material,
      InvoiceRecordModel record,
      Map<String, double> totals,
      ) async {
    final rawName = (material.matName/*?.decodeProblematic()*/ ?? '');
    final safeLen = (rawName.length).clamp(0, 64);
    final itemName = rawName.substring(0, safeLen);

    final cleaned = itemName
        .replaceAll(RegExp(r'[^\x20-\x7Eء-ي\u0640]'), '')
        .replaceAll('ـ', ' ');
    final translatedName = await _translationRepository.translateText(cleaned);

    return [
      ...generator.text(translatedName, styles: PrinterTextStyles.left),
      ...generator.text(material.matBarCode ?? '', styles: PrinterTextStyles.left),
      ...generator.text(
        '${record.invRecQuantity} x ${totals['unitPriceWithVat']!.toStringAsFixed(2)} -> '
            '${PrinterConstants.totalLabel}${totals['lineTotal']!.toStringAsFixed(2)}',
        styles: PrinterTextStyles.left,
        linesAfter: 1,
      ),
    ];
  }

  // شعار آمن (يمنع أخطاء القوائم الثابتة)
  Future<List<int>> _generateLogo(Generator generator) async {
    try {
      // 1) حمّل الصورة وفكّ ترميزها
      final data = await rootBundle.load(AppAssets.ba3Logo);
      final img.Image? decoded =
      img.decodeImage(Uint8List.fromList(data.buffer.asUint8List()));
      if (decoded == null) {
        debugPrint('Logo decode failed');
        return const <int>[];
      }

      // 2) احسب أقصى عرض بالنقاط بناءً على مقاس الورق (203dpi شائع)
      // mm80 ≈ 576dots, mm58 ≈ 384dots
      final int maxDots =
      (PrinterConstants.paperSize == PaperSize.mm80) ? 576 : 384;

      // استعمل قيمة مخصّصة لو موجودة، لكن لا تتجاوز maxDots
      final int targetWidth = (PrinterConstants.logoWidthPx)
          .clamp(64, maxDots); // حد أدنى 64 حتى نتجنّب مشاكل صغيرة

      // 3) غيّر الحجم مع الحفاظ على النسبة
      final img.Image resized = img.copyResize(
        decoded,
        width: targetWidth,
        interpolation: img.Interpolation.average,
        // preserveAspectRatio: true,
      );

      // 4) بعض الرولات تتطلّب عرضًا مضاعفًا لـ 8
      final int w8 = resized.width - (resized.width % 8);
      final img.Image ready =
      (w8 == resized.width) ? resized : img.copyResize(resized, width: w8);

      // 5) جرّب raster أولاً (أجود). لو فشل لأي سبب، fallback إلى image()
      try {
        final bytes = generator.imageRaster(
          ready,
          align: PosAlign.center,
        );
        return List<int>.from(bytes, growable: true);
      } catch (e) {
        debugPrint('imageRaster failed, fallback to image(): $e');
        final bytes = generator.image(
          ready,
          align: PosAlign.center,
        );
        return List<int>.from(bytes, growable: true);
      }
    } catch (e) {
      debugPrint('Logo generation error: $e');
      // لا توقف الطباعة بسبب الشعار
      return const <int>[];
    }
  }


  List<int> _createHeaderSection(Generator generator, String date, int billNumber,String sellerName,String customerNumber) {
    return [
      ...generator.emptyLines(2),
      ...generator.text(PrinterConstants.storeName, styles: PrinterTextStyles.boldCentered),
      ...generator.emptyLines(1),
      ...generator.text('${PrinterConstants.dateLabel}$date', styles: PrinterTextStyles.left),
      ...generator.text('${PrinterConstants.billNumberLabel}$billNumber', styles: PrinterTextStyles.left),
      ...generator.text('${PrinterConstants.sellerName}$sellerName', styles: PrinterTextStyles.left),
      ...generator.text('${PrinterConstants.customerNumber}$customerNumber', styles: PrinterTextStyles.left),
      ...generator.text(PrinterConstants.trnNumber, styles: PrinterTextStyles.left, linesAfter: 1),
    ];
  }

  List<int> _generateTotalSummary(Generator generator, double netTotal, double vatTotal) {
    return [
      ...generator.text('${PrinterConstants.totalVatLabel}${vatTotal.toStringAsFixed(2)}', styles: PrinterTextStyles.centered),
      ...generator.text('-' * 30, styles: PrinterTextStyles.right),
      ...generator.text('${PrinterConstants.subTotalLabel}${netTotal.toStringAsFixed(2)} AED', styles: PrinterTextStyles.rightBold),
      ...generator.text('${PrinterConstants.vatLabel}${vatTotal.toStringAsFixed(2)} AED', styles: PrinterTextStyles.rightBold),
      ...generator.text('${PrinterConstants.totalLabel}${(netTotal + vatTotal).toStringAsFixed(2)} AED', styles: PrinterTextStyles.rightBold),
      ...generator.emptyLines(1),
    ];
  }

  List<int> _createFooterSection(Generator generator) {
    return [
      ...generator.text(PrinterConstants.storeLocation, styles: PrinterTextStyles.centered),
      ...generator.text(PrinterConstants.contactNumber, styles: PrinterTextStyles.centered),
      ...generator.text(PrinterConstants.thankYouMessage, styles: PrinterTextStyles.boldCentered),
      ...generator.emptyLines(2),
    ];
  }
}



class PrinterConstants {
  // أسماء الطابعات
  static const String printerNameWindows = 'POS58';
  static const String printerNameMac = 'POS58';

  // مقاس الورق (POS80 عادةً 80mm)
  static final PaperSize paperSize = PaperSize.mm58;

  // عرض اللوجو المقترح
  static final int logoWidthPx = paperSize == PaperSize.mm58 ? 200 : 300;

  // نصوص ثابتة

  static const String dateLabel = 'Date: ';
  static const String billNumberLabel = 'Invoice #: ';
  static const String sellerName = 'Seller Name #: ';
  static const String customerNumber = 'Customer Number #: ';
  static const String invoiceTitle = 'TAX INVOICE';
  static const String storeName = 'Burj Al Arab Mobile Phones';
  static const String trnNumber = 'TRN:  100369311400003';
  static const String storeLocation = 'Ras Al Khaimah, UAE';
  static const String contactNumber = '+971-56-866-6411';
  static const String thankYouMessage = 'Thank you for your purchase!';
  static const String totalVatLabel = 'VAT Amount: ';
  static const String subTotalLabel = 'Sub Total: ';
  static const String vatLabel = 'VAT (5%): ';
  static const String totalLabel = 'Total: ';


}