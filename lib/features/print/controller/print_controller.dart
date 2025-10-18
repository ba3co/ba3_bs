// lib/features/print/controller/printing_controller.dart

import 'package:get/get.dart';

import '../core/print_job.dart';
import '../core/printer_device.dart';
import '../core/print_result.dart';
import '../service/printer_manager.dart';
import '../templates/label_template.dart';

// للِّيبل (باركود) نحتاج الجنريتور والملف الشخصي
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../escpos/escpos_generator.dart';

// في حال أردت إرسال بايتات الليبل مباشرة (بدون PrinterManager)
import '../io/print_adapter.dart';
import '../io/windows_raw_adapter.dart';
import '../io/macos_raw_adapter.dart';
import '../../bill/data/models/invoice_record_model.dart';

class PrintingController extends GetxController {
  final PrinterManager manager;
  PrintingController(this.manager);

  // =======================
  // 58mm Receipt
  // =======================
  Future<PrintResult> printReceipt58({
    required List<InvoiceRecordModel> items,
    required int billNumber,
    required String date,
    required String seller,
    required String customer,
  }) async {
    final job = PrintJob(
      billNumber: billNumber,
      invoiceDate: date,
      sellerName: seller,
      customerNumber: customer,
      items: items,
    );

    final device = PrinterDevice(
      name: 'POS58',
      paperKind: PaperKind.mm58,
      platform:
      GetPlatform.isWindows ? PlatformKind.windows : PlatformKind.macos,
    );

    return manager.printJob(device, job);
  }

  // =======================
  // 80mm Receipt
  // =======================
  Future<PrintResult> printReceipt80({
    required List<InvoiceRecordModel> items,
    required int billNumber,
    required String date,
    required String seller,
    required String customer,
  }) async {
    final job = PrintJob(
      billNumber: billNumber,
      invoiceDate: date,
      sellerName: seller,
      customerNumber: customer,
      items: items,
    );

    final device = PrinterDevice(
      name: 'POS80',
      paperKind: PaperKind.mm80,
      platform:
      GetPlatform.isWindows ? PlatformKind.windows : PlatformKind.macos,
    );

    return manager.printJob(device, job);
  }

  // =======================
  // Label (barcode-only)
  // =======================
  Future<PrintResult> printLabel({
    required String printerName,
    required String barcodeData,
    String? title,
  }) async {
    // نحدد نوع الجهاز كـ Label (معظم الليبلرز ESC/POS عرض 58mm افتراضياً)
    final device = PrinterDevice(
      name: printerName,
      paperKind: PaperKind.label,
      platform:
      GetPlatform.isWindows ? PlatformKind.windows : PlatformKind.macos,
    );

    // نبني البايتات عبر التمبلِيت
    final profile = await CapabilityProfile.load();
    final generator = EscposGenerator(
      PaperSize.mm58, // عدّلها لو ليبلر أوسع
      profile,
    );

    final labelTemplate = LabelTemplate(data: barcodeData, title: title);
    final bytes = await labelTemplate.build(
      generator,
      const PrintJob(
        billNumber: 0,
        invoiceDate: '',
        sellerName: '',
        customerNumber: '',
        items: [],
      ),
    );

    // نرسل البايتات عبر المحول المناسب للمنصة
    final adapter = _adapterFor(device.platform);
    return adapter.send(bytes, printerName: device.name);
  }

  // =======================
  // Helpers
  // =======================
  PrintAdapter _adapterFor(PlatformKind platform) {
    return platform == PlatformKind.windows
        ? WindowsRawAdapter()
        : MacosRawAdapter();
  }
}