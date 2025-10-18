

import 'package:ba3_bs/features/print/service/translation_service.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../core/printer_device.dart';
import '../core/print_job.dart';
import '../core/print_result.dart';
import '../escpos/escpos_generator.dart';
import '../io/print_adapter.dart';
import '../io/macos_raw_adapter.dart';
import '../io/windows_raw_adapter.dart';
import '../templates/base_template.dart';
import '../templates/receipt_template_58.dart';
import '../templates/receipt_template_80.dart';


class PrinterManager {
  final Map<PaperKind, BaseTemplate> _templates;
  final TranslationService ts;

  PrinterManager({BaseTemplate? t58, BaseTemplate? t80,required this.ts})
      : _templates = {
    if (t58 != null) PaperKind.mm58: t58,
    if (t80 != null) PaperKind.mm80: t80,
  };


  PrintAdapter _adapterFor(PlatformKind p) =>
      p == PlatformKind.windows ? WindowsRawAdapter() : MacosRawAdapter();


  Future<PrintResult> printJob(PrinterDevice device, PrintJob job) async {
    final profile = device.profile ?? await CapabilityProfile.load();


    final BaseTemplate template = switch (device.paperKind) {
      PaperKind.mm58 => _templates[PaperKind.mm58] ?? ReceiptTemplate58(ts),
      PaperKind.mm80 => _templates[PaperKind.mm80] ?? ReceiptTemplate80(ts),
      PaperKind.label => throw UnimplementedError('Use LabelTemplate directly'),
    };


    final g = EscposGenerator(
      switch (device.paperKind) {
        PaperKind.mm58 => PaperSize.mm58,
        PaperKind.mm80 => PaperSize.mm80,
        PaperKind.label => PaperSize.mm58, // adjust if your labeler is wider
      },
      profile,
    );


    final bytes = await template.build(g, job);
    final adapter = _adapterFor(device.platform);
    return adapter.send(bytes, printerName: device.name);
  }
}