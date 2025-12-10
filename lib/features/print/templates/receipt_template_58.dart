import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../core/print_job.dart';
import '../escpos/escpos_generator.dart';
import '../escpos/logo_helper.dart';
import '../service/translation_service.dart';
import 'base_template.dart';

class ReceiptTemplate58 implements BaseTemplate {
  final TranslationService ts;

  ReceiptTemplate58(this.ts);

  @override
  PaperSize get paperSize => PaperSize.mm58;

  @override
  Future<List<int>> build(EscposGenerator g, PrintJob job) async {
    final b = <int>[];

    b.addAll(g.reset());
    b.addAll(g.text('TAX INVOICE',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          height: PosTextSize.size2,
        )));
    b.addAll(g.empty());

    // // LOGO small - left side
    final logo = await LogoHelper.generateLogo(paperSize);
    if (logo.isNotEmpty) {
 /*     b.addAll([0x1B, 0x61, 0x00]); // ESC a 0 = Align Left*/

      b.addAll(logo);
      b.addAll(g.text('', styles: const PosStyles(align: PosAlign.left)));
    }
    b.addAll(g.reset());
    b.addAll(g.text('Burj Al Arab Mobile Phones',
        styles: const PosStyles(align: PosAlign.left, bold: true)));

    b.addAll(g.text('Ras Al Khaimah, UAE',
        styles: const PosStyles(align: PosAlign.left)));

    b.addAll(g.text('Sheikh Muhammad Bin Salem Street',
        styles: const PosStyles(align: PosAlign.left)));

    b.addAll(g.text('Tel: +971 56 866 6411',
        styles: const PosStyles(align: PosAlign.left)));

    b.addAll(g.text('TRN: 100369311400003',
        styles: const PosStyles(align: PosAlign.left, bold: true)));

    // Invoice Info
    b.addAll(g.text('Invoice #: ${job.billNumber}',
        styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Date: ${job.invoiceDate}',
        styles: const PosStyles(align: PosAlign.left)));
    final seller = await ts.safeTranslate(job.sellerName );
    final nots = await ts.safeTranslate(job.nots );
    final buyer = await ts.safeTranslate(job.buyer );
    b.addAll(g.text('Seller: $seller',
        styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Buyer: $buyer',
        styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Note: $nots',
        styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.hr());

    b.addAll(g.empty(2));
    b.addAll(g.hr());

    // // Items Header
    // b.addAll(g.text(
    //   'Item                         Qty    Amount',
    //   styles: const PosStyles(bold: true),
    // ));
    // b.addAll(g.hr());

    double net = 0, vat = 0;

    // Items Printing
    for (final r in job.items) {
      final qty = r.invRecQuantity ?? 1;
      final total = r.invRecTotal ?? 0;
      final name = await ts.safeTranslate(r.invRecProduct ?? '');

      final unit = total / qty;
      final vatU = (unit/1.05) * 0.05;
      final netU = unit - vatU;

      vat += vatU * qty;
      net += netU * qty;

      final trimmed =
      name.length > 25 ? name.substring(0, 25) : name.padRight(25);

      // اسم المنتج
      b.addAll(g.text(
        trimmed,
        styles: const PosStyles(align: PosAlign.left),
      ));
      if (r.invRecProductSoldSerial != null &&
          r.invRecProductSoldSerial!.isNotEmpty) {
        // السيريال
        b.addAll(g.text(
          "Serial No: ${r.invRecProductSoldSerial}",
          styles: const PosStyles(align: PosAlign.left),
        ));

        b.addAll(g.empty());
      }
      // العناوين (مع تنسيق أعمدة)
      b.addAll(g.row([
        PosColumn(
          text: 'Unit Price',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'VAT%',
          width: 3,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: 'Qty',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));

      b.addAll(g.row([
        PosColumn(
          text: unit.toStringAsFixed(2),
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: "5.0%",
          width: 3,
          styles: const PosStyles(align: PosAlign.center),
        ),
        PosColumn(
          text: qty.toString(),
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));

      b.addAll(g.empty());
      b.addAll(g.row([
        PosColumn(
          text: 'Unit Price',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'VAT',
          width: 3,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: 'Total',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));

      b.addAll(g.row([
        PosColumn(
          text: '${unit.toStringAsFixed(2)} AED',
          width: 6,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${vatU.toStringAsFixed(2)} AED',
          width: 3,
          styles: const PosStyles(align: PosAlign.left),
        ),
        PosColumn(
          text: '${total.toStringAsFixed(2)} AED',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]));
    }

    b.addAll(g.hr());

    final totalAmount = (net + vat);

    b.addAll(g.text(
      'Subtotal:${net.toStringAsFixed(2)} AED',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    ));
    b.addAll(g.text(
      'VAT (5%):${vat.toStringAsFixed(2)} AED',
      styles: const PosStyles(align: PosAlign.left, bold: true),
    ));
    b.addAll(g.text(
      'Total Amount:${totalAmount.toStringAsFixed(2)} AED',
      styles: const PosStyles(
          align: PosAlign.left, bold: true, height: PosTextSize.size1),
    ));

    b.addAll(g.hr());

    // Footer (Apple like)
    b.addAll(g.text('Thank you for your purchase!',
        styles: const PosStyles(align: PosAlign.left)));
    b.addAll(g.text('Powered by: Burj Al Arab Mobile Phones',
        styles: const PosStyles(align: PosAlign.center)));

    b.addAll(g.empty());
    b.addAll(g.cut());

    return b;
  }}