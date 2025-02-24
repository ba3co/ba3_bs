// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:ba3_bs/core/constants/app_assets.dart';
import 'package:ba3_bs/core/constants/printer_constants.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;

import '../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../core/services/translation/implementations/translation_repo.dart';
import '../../../core/styling/printer_text_styles.dart';
import '../../bill/data/models/invoice_record_model.dart';
import '../../materials/data/models/materials/material_model.dart';
import '../ui/widgets/printing_loading_dialog.dart';

class PrintingController extends GetxController {
  final TranslationRepository _translationRepository;

  PrintingController(this._translationRepository);

  bool isPrinterConnected = false;

  // إدارة قائمة الطابعات المكتشفة
  List<Printer> printers = [];
  RxString loadingDots = ''.obs;
  Timer? _loadingAnimationTimer;

  // استخدام instance من flutter_thermal_printer
  final FlutterThermalPrinter _thermalPrinter = FlutterThermalPrinter.instance;
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    _startLoadingDotsAnimation();

    // الاشتراك في تيار نتائج البحث عن الطابعات لتحديث القائمة
    _devicesStreamSubscription = _thermalPrinter.devicesStream.listen((List<Printer> scannedPrinters) {
      printers = scannedPrinters;
      debugPrint('Scanned printers: ${printers.map((e) => e.name).toList()}');
    });

    // بدء البحث عن الطابعات عند بدء التشغيل
    startScan();
  }

  @override
  void onClose() {
    _loadingAnimationTimer?.cancel();
    _devicesStreamSubscription?.cancel();
    super.onClose();
  }

  void _startLoadingDotsAnimation() {
    _loadingAnimationTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      loadingDots.value = loadingDots.value.length < 3 ? '${loadingDots.value}.' : '';
    });
  }

  /// يبدأ عملية البحث عن الطابعات باستخدام flutter_thermal_printer
  void startScan() async {
    _devicesStreamSubscription?.cancel();
    // استدعاء الدالة getPrinters مع أنواع الاتصال المطلوبة (USB وBLE هنا)
    await _thermalPrinter.getPrinters(
      connectionTypes: [ConnectionType.USB, ConnectionType.BLE],
      refreshDuration: const Duration(seconds: 2),
    );
    // النتائج ستُحدّث من خلال devicesStream
  }

  void stopScan() {
    _thermalPrinter.stopScan();
  }

  Future<void> startPrinting({
    required BuildContext context,
    required int billNumber,
    required List<InvoiceRecordModel> invRecords,
    required String invDate,
  }) async {
    _showLoadingDialog(context);
    await _printBill(billNumber: billNumber, invRecords: invRecords, invDate: invDate);
    _dismissLoadingDialog();
  }

  /// يعرض نافذة تحميل أثناء عملية الطباعة
  void _showLoadingDialog(BuildContext context) {
    OverlayService.showDialog(
      context: context,
      title: '',
      width: 250,
      height: 100,
      content: const PrintingLoadingDialog(),
      contentPadding: EdgeInsets.zero,
      onCloseCallback: () {
        Get.delete<PrintingController>();
      },
    );
  }

  void _dismissLoadingDialog() => OverlayService.back();

  /// يبحث عن الطابعة المطلوبة (بناءً على MAC address المخزن في PrinterConstants)
  Future<void> _printBill({
    required int billNumber,
    required List<InvoiceRecordModel> invRecords,
    required String invDate,
  }) async {
    // ننتظر قليلاً لضمان استقبال نتائج البحث عبر devicesStream
    await Future.delayed(const Duration(seconds: 3));

    const String targetPrinterMacAddress = PrinterConstants.printerMacAddress;

    // التحقق من وجود الطابعة المطلوبة باستخدام MAC address
    bool isPrinterAvailable = printers.any((printer) {
      String? addr = printer.address;
      return addr != null && addr.toLowerCase() == targetPrinterMacAddress.toLowerCase();
    });

    if (isPrinterAvailable) {
      Printer targetPrinter = printers.firstWhere((printer) {
        return printer.address != null && printer.address!.toLowerCase() == targetPrinterMacAddress.toLowerCase();
      });
      if (!isPrinterConnected) {
        await _connectToPrinter(targetPrinter);
      }
      await _sendBillToPrinter(targetPrinter, invRecords, invDate, billNumber);
    } else {
      debugPrint('Cannot find the printer');
    }
  }

  /// الاتصال بالطابعة
  Future<void> _connectToPrinter(Printer printer) async {
    // استدعاء دالة connect بالطابعة المُحددة
    isPrinterConnected = await _thermalPrinter.connect(
      printer,
    );
    debugPrint('Connection status: $isPrinterConnected');
  }

  /// فصل الاتصال بالطابعة
  Future<void> _disconnectFromPrinter(Printer printer) async {
    await _thermalPrinter.disconnect(printer);
    debugPrint('Disconnect status: $isPrinterConnected');
  }

  /// إرسال بيانات الفاتورة إلى الطابعة
  Future<void> _sendBillToPrinter(Printer printer, List<InvoiceRecordModel> invRecords, String invDate, int billNumber) async {
    if (isPrinterConnected) {
      List<int> ticket = await _generateBillPrintData(invRecords, invDate, billNumber);
      await _thermalPrinter.printData(printer, ticket, longData: true); // تم استبدال printTicket بـ writeBytes
    } else {
      debugPrint('Print connection status: false');
    }
  }

  /// توليد بيانات الطباعة باستخدام esc_pos_utils_plus
  Future<List<int>> _generateBillPrintData(List<InvoiceRecordModel> invoiceRecords, String invoiceDate, int billNumber) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm58, profile);
    List<int> bytes = generator.reset();

    // الهيدر
    bytes += generator.text(PrinterConstants.invoiceTitle, styles: PrinterTextStyles.centered, linesAfter: 1);
    bytes += await _generateLogo(generator);
    bytes += _createHeaderSection(generator, invoiceDate, billNumber);

    // معالجة البنود وتوليد تفاصيل العناصر والإجماليات
    final result = await _generateItemsDetailsAndTotals(generator, invoiceRecords);
    bytes += result.bytes;

    // ملخص الإجمالي
    bytes += _generateTotalSummary(generator, result.totals['netAmount']!, result.totals['vatAmount']!);

    // الفوتر
    bytes += _createFooterSection(generator);

    return bytes;
  }

  Future<({List<int> bytes, Map<String, double> totals})> _generateItemsDetailsAndTotals(Generator generator,
      List<InvoiceRecordModel> invoiceRecords) async {
    double netAmount = 0;
    double vatAmount = 0;
    List<int> itemBytes = [];

    final materialController = read<MaterialController>();

    for (var record in invoiceRecords) {
      final material = materialController.getMaterialById(record.invRecId!);
      final recordTotals = _computeRecordTotals(record);

      netAmount += recordTotals['netTotal']!;
      vatAmount += recordTotals['vatTotal']!;

      itemBytes += await _generateItemDetails(generator, material!, record, recordTotals);
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

  Future<List<int>> _generateItemDetails(Generator generator, MaterialModel material, InvoiceRecordModel record, Map<String, double> totals) async {
    final itemName = (material.matName ?? '').substring(0, (material.matName?.length ?? 0).clamp(0, 64));
    return [
      ...generator.text(itemName, styles: PrinterTextStyles.left),
      ...generator.text(material.matBarCode ?? '', styles: PrinterTextStyles.left),
      ...generator.text(
        '${record.invRecQuantity} x ${totals['unitPriceWithVat']!.toStringAsFixed(2)} -> ${PrinterConstants.totalLabel}${totals['lineTotal']!
            .toStringAsFixed(2)}',
        styles: PrinterTextStyles.left,
        linesAfter: 1,
      ),
    ];
  }

  Future<List<int>> _generateLogo(Generator generator) async {
    try {
      final ByteData data = await rootBundle.load(AppAssets.ba3Logo);
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

  List<int> _createHeaderSection(Generator generator, String date, int billNumber) {
    return [
      ...generator.emptyLines(2),
      ...generator.text(PrinterConstants.storeName, styles: PrinterTextStyles.boldCentered),
      ...generator.emptyLines(1),
      ...generator.text('${PrinterConstants.dateLabel}$date', styles: PrinterTextStyles.left),
      ...generator.text('${PrinterConstants.billNumberLabel}$billNumber', styles: PrinterTextStyles.left),
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
