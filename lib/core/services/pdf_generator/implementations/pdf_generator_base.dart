import 'dart:developer';
import 'dart:io';

import 'package:ba3_bs/core/constants/printer_constants.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../constants/app_assets.dart';
import '../interfaces/i_pdf_generator.dart';
import 'package:file_selector/file_selector.dart';
abstract class PdfGeneratorBase<T> implements IPdfGenerator<T> {
  @override
  Widget buildHeader(T itemModel, String fileName,
      {Uint8List? logoUint8List, Font? font});

  @override
  List<Widget> buildBody(T itemModel, {Font? font,Uint8List?logoUint8List});

  @override
  Widget buildFooter() => Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Divider(),
          SizedBox(height: 2 * PdfPageFormat.mm),
          buildSimpleText(title: 'Thank You To Visit: ', value: 'Burj ALArab Mobile Phones'),
          buildSimpleText(
              title: 'Phone: ', value: PrinterConstants.contactNumber),

        ],
      ));

  buildSimpleText({required String title, required String value}) {
    final style = TextStyle(fontWeight: FontWeight.bold);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(title, style: style),
        SizedBox(width: 2 * PdfPageFormat.mm),
        Text(value),
      ],
    );
  }

  @override
  Future<String> generatePdf(T itemModel, String fileName,
      {String? logoSrc, String? fontSrc}) async {
    final Uint8List? logoUint8List;
    final Font? arabicFont;
    // Load the logo if provided
      ByteData logoByteData = await rootBundle.load(AppAssets.printLogo);
      logoUint8List = logoByteData.buffer.asUint8List();

    // Load the font if provided
    if (fontSrc == null) {
      arabicFont = null;
    } else {
      log('fontSrc $fontSrc');
      ByteData fontByteData = await rootBundle.load(fontSrc);
      // arabicFont = Font.ttf(fontByteData.buffer.asByteData());
      arabicFont = Font.ttf(fontByteData);
    }

    final pdfTheme = ThemeData.withFont(
      base: arabicFont,
      bold: arabicFont,
      italic: arabicFont,
      boldItalic: arabicFont,
    );

    final Document pdfDocument = Document(theme: pdfTheme);

    pdfDocument.addPage(
      MultiPage(
        header: (context) {
          // Display the header only on the first page
          if (context.pageNumber == 1) {
            return buildHeader(itemModel, fileName,
                logoUint8List: logoUint8List, font: arabicFont);
          }
          return SizedBox.shrink(); // Return an empty container instead of null
        },
        build: (context) => buildBody(itemModel, font: arabicFont),
        footer: (context) {
          // Display the footer only on the last page
          if (context.pageNumber == context.pagesCount) {
            return buildFooter();
          }
          return SizedBox.shrink(); // Return an empty container instead of null
        },
      ),
    );

    // Save the PDF locally
    final directory = await getApplicationDocumentsDirectory();

    final updatedFileName =
        '${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final filePath = '${directory.path}/$updatedFileName';

    final file = File(filePath);
    await file.writeAsBytes(await pdfDocument.save());
    return filePath;
  }
  @override
  Future<String> generatePdfInLocation(
      T itemModel,
      String fileName, {
        String? logoSrc,
        String? fontSrc,
      }) async {
    final bytes = await _buildPdfBytes(
      itemModel,
      fileName,
      logoSrc: logoSrc,
      fontSrc: fontSrc,
    );

    // نافذة "حفظ باسم…"
    final String? path = await getSaveLocation(
      suggestedName: '${fileName}_${DateTime.now().millisecondsSinceEpoch}.pdf',
      acceptedTypeGroups: [
        XTypeGroup(label: 'PDF', extensions: ['pdf']),
      ],
    ).then((value) => value?.path);

    if (path == null) {
      // المستخدم أغلق الحوار -> لا نحفظ
      return 'false';
    }

    final file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  Future<Uint8List> _buildPdfBytes(
      T itemModel,
      String fileName, {
        String? logoSrc,
        String? fontSrc,
      }) async {
    // Load logo (استبدلت AppAssets.printLogo إذا عندك logoSrc)
    Uint8List? logoUint8List;
    final String logoPath = logoSrc ?? AppAssets.printLogo;
    final ByteData logoByteData = await rootBundle.load(logoPath);
    logoUint8List = logoByteData.buffer.asUint8List();

    // Load font (اختياري)
    Font? arabicFont;
    if (fontSrc != null) {
      final ByteData fontByteData = await rootBundle.load(fontSrc);
      arabicFont = Font.ttf(fontByteData);
    }

    final pdfTheme = ThemeData.withFont(
      base: arabicFont,
      bold: arabicFont,
      italic: arabicFont,
      boldItalic: arabicFont,
    );

    final doc = Document(theme: pdfTheme);

    doc.addPage(
      MultiPage(
        // ⚠️ لا نحدد pageFormat هنا (يظل الافتراضي مثل دالتك الأولى)
        header: (context) =>
        context.pageNumber == 1
            ? buildHeader(itemModel, fileName, logoUint8List: logoUint8List, font: arabicFont)
            : SizedBox.shrink(),
        build: (context) => buildBody(itemModel, font: arabicFont),
        footer: (context) =>
        context.pageNumber == context.pagesCount ? buildFooter() : SizedBox.shrink(),
      ),
    );

    return await doc.save();
  }
}