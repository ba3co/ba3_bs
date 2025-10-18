import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../core/print_job.dart';
import '../escpos/escpos_generator.dart';
import '../escpos/barcode_helpers.dart';
import '../service/translation_service.dart';
import 'base_template.dart';

class LabelTemplate implements BaseTemplate {
  @override
  PaperSize get paperSize => PaperSize.mm58; // عدّلها إذا اللّيبلر أعرض

  final String data;      // قيمة الباركود (SKU/EAN/Code128)
  final String? title;    // عنوان اختياري فوق الباركود
  final TranslationService? ts;

  LabelTemplate({required this.data, this.title, this.ts});

  @override
  Future<List<int>> build(EscposGenerator g, PrintJob job) async {
    final b = <int>[];
    b.addAll(g.reset());

    if (title != null && title!.isNotEmpty) {
      final t = ts == null ? title! : await ts!.safeTranslate(title!);
      b.addAll(g.text(t, styles: const PosStyles(align: PosAlign.center, bold: true)));
    }

    // باركود (Code128 مناسب لمعظم الحالات)
    b.addAll(g.barcode(
      Barcodes.forLabel(data),
      data: data,
      width: 3,
      height: 120,
    ));

    // طباعة النص تحت الباركود (يمين/يسار/وسط حسب رغبتك)
    b.addAll(g.text(
      data,
      styles: const PosStyles(align: PosAlign.center),
    ));

    b.addAll(g.cut());
    return b;
  }
}