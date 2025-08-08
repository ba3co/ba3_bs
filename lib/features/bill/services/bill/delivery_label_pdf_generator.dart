import 'dart:typed_data';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/widgets.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../../data/models/delivery_item_model.dart';

class DeliveryLabelPdfGenerator extends PdfGeneratorBase<DeliveryModel> {
  @override
  pw.Widget buildHeader(DeliveryModel itemModel, String fileName,
      {Uint8List? logoUint8List, pw.Font? font}) {
    return pw.SizedBox(); // No header needed
  }

  @override
  List<pw.Widget> buildBody(DeliveryModel itemModel, {pw.Font? font}) {
    final totalPrice = itemModel.items.fold<double>(
      0.0,
          (sum, item) => sum + (item.quantity * item.price),
    );

    final barcodeWidget = pw.BarcodeWidget(
      data: itemModel.orderId,
      barcode: Barcode.code128(),
      width: double.infinity,
      height: 50,
    );

    return [
      // ✅ اسم المتجر
      pw.Center(
        child: pw.Text('برج العرب للهواتف',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
            textDirection: pw.TextDirection.rtl),
      ),

      pw.SizedBox(height: 6),

      // ✅ معلومات الطلب
      _infoRow('رقم الطلبية', itemModel.orderId, font),
      _infoRow('تاريخ التوصيل',
          itemModel.orderDate.add(Duration(days: 1)).dayMonthYear, font),
      _infoRow('اسم ورقم العميل', itemModel.recipientName, font),
      _infoRow('رقم العميل', itemModel.phone, font),
      _infoRow('عنوان التسليم', itemModel.address, font),

      pw.SizedBox(height: 8),

      // ✅ عنوان جدول العناصر
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        children: [
          pw.Text('تفاصيل العناصر:',
              style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                font: font,
              ),
              textDirection: pw.TextDirection.rtl),
        ],
      ),

      pw.SizedBox(height: 4),

      // ✅ جدول العناصر
      pw.Table(
        border: pw.TableBorder.all(width: 0.5),
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        columnWidths: {
          0: pw.FlexColumnWidth(2), // اسم المادة
          1: pw.FlexColumnWidth(1), // الكمية
          2: pw.FlexColumnWidth(1), // السعر
        },
        children: [
          // Header
          pw.TableRow(
            decoration: pw.BoxDecoration(color: PdfColors.grey300),
            children: [
              _tableCell('العنصر', font, isBold: true),
              _tableCell('الكمية', font, isBold: true),
              _tableCell('السعر', font, isBold: true),
            ],
          ),
          // البيانات
          ...itemModel.items.map((item) => pw.TableRow(
            children: [
              _tableCell(item.name, font),
              _tableCell(item.quantity.toString(), font),
              _tableCell(item.price.toStringAsFixed(2), font),
            ],
          )),
        ],
      ),

      pw.SizedBox(height: 5),

      // ✅ الإجمالي
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'الإجمالي: ${totalPrice.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            font: font,
          ),
          textDirection: pw.TextDirection.rtl,
        ),
      ),

      pw.SizedBox(height: 10),

      // ✅ باركود
      barcodeWidget,
    ];
  }

  // ✅ عنصر من سطرين (التسمية والقيمة)
  pw.Widget _infoRow(String label, String value, pw.Font? font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: [
        pw.Text(value,
            style: pw.TextStyle(fontSize: 8, font: font),
            textDirection: pw.TextDirection.rtl),
        pw.SizedBox(width: 4),
        pw.Text('$label:',
            style: pw.TextStyle(
                fontSize: 8, fontWeight: pw.FontWeight.bold, font: font),
            textDirection: pw.TextDirection.rtl),
      ],
    );
  }

  // ✅ خلية جدول موحدة التنسيق
  pw.Widget _tableCell(String text, pw.Font? font, {bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(2), // ✅ تصغير الـ padding
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 7, // ✅ تصغير الخط
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          font: font,
        ),
        textDirection: pw.TextDirection.rtl,
      ),
    );
  }

  @override
  pw.Widget buildFooter() => pw.SizedBox();
}