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

    // LOGO FIX
    final logo = await LogoHelper.generateLogo(paperSize);
    if (logo.isNotEmpty) {
      b.addAll(logo);
      b.addAll(g.empty());
    }

    b.addAll(g.text('TAX INVOICE',
        styles: const PosStyles(align: PosAlign.center, bold: true)));

    b.addAll(g.text('Burj Al Arab Mobile Phones',
        styles: const PosStyles(align: PosAlign.center, bold: true)));
    b.addAll(g.text('Ras Al Khaimah, UAE',
        styles: const PosStyles(align: PosAlign.center)));
    b.addAll(g.text('Sheikh Muhammad Bin Salem Street',
        styles: const PosStyles(align: PosAlign.center)));
    b.addAll(g.text('Units 1+2+3',
        styles: const PosStyles(align: PosAlign.center)));
    b.addAll(g.text('Tel: +971 56 866 6411',
        styles: const PosStyles(align: PosAlign.center)));
    b.addAll(g.text('TRN: 100369311400003',
        styles: const PosStyles(align: PosAlign.center, bold: true)));
    b.addAll(g.hr());

    b.addAll(g.text('Invoice #: ${job.billNumber}'));
    b.addAll(g.text('Date: ${job.invoiceDate}'));
    b.addAll(g.text('Cashier: Ali'));
    b.addAll(g.hr());

    b.addAll(g.text('Item                        Qty     Total',
        styles: const PosStyles(bold: true)));
    b.addAll(g.hr());

    double net = 0, vat = 0;

    for (final r in job.items) {
      final name = await ts.safeTranslate(r.invRecProduct ?? '');
      final qty = r.invRecQuantity ?? 1;
      final total = r.invRecTotal ?? 0;
      final unitPrice = total / qty;
      final vatUnit = unitPrice * 0.05;
      final netUnit = unitPrice - vatUnit;

      vat += vatUnit * qty;
      net += netUnit * qty;

      b.addAll(g.text(
        '${name.padRight(24).substring(0,24)}'
            '${qty.toString().padLeft(3)}'
            '${total.toStringAsFixed(2).padLeft(8)}',
      ));
    }

    b.addAll(g.hr());

    b.addAll(g.text('Subtotal:      ${net.toStringAsFixed(2)} AED',
        styles: const PosStyles(bold: true)));
    b.addAll(g.text('VAT (5%):      ${vat.toStringAsFixed(2)} AED',
        styles: const PosStyles(bold: true)));
    b.addAll(g.text('TOTAL:       ${(net + vat).toStringAsFixed(2)} AED',
        styles: const PosStyles(bold: true, height: PosTextSize.size2)));
    b.addAll(g.hr());

    b.addAll(g.empty());
    b.addAll(g.text('Thank you for your purchase!',
        styles: const PosStyles(align: PosAlign.center)));
    b.addAll(g.text('Goods sold are not returnable unless faulty.',
        styles: const PosStyles(align: PosAlign.center)));

    b.addAll(g.empty(2));
    b.addAll(g.cut());

    return b;
  }
}