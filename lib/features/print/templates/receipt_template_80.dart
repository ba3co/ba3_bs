import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../core/print_job.dart';
import '../escpos/escpos_generator.dart';
import '../escpos/logo_helper.dart';
import '../service/translation_service.dart';
import 'base_template.dart';

class ReceiptTemplate80 implements BaseTemplate {
  final TranslationService ts;

  ReceiptTemplate80(this.ts);

  @override
  PaperSize get paperSize => PaperSize.mm80;

  @override
  Future<List<int>> build(EscposGenerator g, PrintJob job) async {
    final b = <int>[];
    b.addAll(g.reset());

    b.addAll(g.text(
      'TAX INVOICE',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 1,
    ));
    b.addAll(g.reset());
    final bytes = await LogoHelper.generateLogo(
      paperSize,
    );
    b.addAll(bytes);
    b.addAll(g.empty());
    b.addAll(g.text(
      'Burj Al Arab Mobile Phones',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 1,
    ));
    final seller = await ts.safeTranslate(job.sellerName);
    final customer = await ts.safeTranslate(job.customerNumber);
    final nots = await ts.safeTranslate(job.nots);

    b.addAll(g.text('Date: ${job.invoiceDate}', styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Invoice #: ${job.billNumber}', styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Seller Name #: $seller', styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Customer Number #: $customer', styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Nots #: $nots', styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('TRN:  100369311400003', styles: const PosStyles(align: PosAlign.left)));

    double net = 0, vat = 0;
    for (final r in job.items) {
      final unit = (r.invRecTotal! / r.invRecQuantity!);
      final vatU = unit * 0.05;
      final netU = unit - vatU;
      net += netU * r.invRecQuantity!;
      vat += vatU * r.invRecQuantity!;

      final raw = (r.invRecProduct ?? '').replaceAll(RegExp(r'[^\x20-\x7Eء-ي\u0640]'), '').replaceAll('ـ', ' ');
      final name = await ts.safeTranslate(raw);

      b.addAll(g.text(name, styles: const PosStyles(align: PosAlign.left)));
      if ((r.invRecProductSoldSerial ?? '').isNotEmpty) {
        b.addAll(g.text(r.invRecProductSoldSerial!, styles: const PosStyles(align: PosAlign.left)));
      }

      b.addAll(
        g.text(
          '${r.invRecQuantity} x ${unit.toStringAsFixed(2)} -> Total ${r.invRecTotal!.toStringAsFixed(2)}',
          styles: const PosStyles(align: PosAlign.left),
          linesAfter: 1,
        ),
      );
    }

    b.addAll(g.text(
      'VAT Amount: ${vat.toStringAsFixed(2)}',
      styles: const PosStyles(align: PosAlign.center),
    ));
    b.addAll(g.text('-' * 48, styles: const PosStyles(align: PosAlign.right)));
    b.addAll(g.text(
      'Sub Total: ${net.toStringAsFixed(2)} AED',
      styles: const PosStyles(align: PosAlign.right, bold: true),
    ));
    b.addAll(g.text(
      'VAT (5%): ${vat.toStringAsFixed(2)} AED',
      styles: const PosStyles(align: PosAlign.right, bold: true),
    ));
    b.addAll(g.text(
      'Total: ${(net + vat).toStringAsFixed(2)} AED',
      styles: const PosStyles(align: PosAlign.right, bold: true),
    ));

    b.addAll(g.empty(2));
    b.addAll(g.cut());
    return b;
  }
}