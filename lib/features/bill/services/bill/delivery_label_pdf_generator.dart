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
    // لا يوجد هيدر في هذا القالب
    return pw.SizedBox();
  }

  @override
  List<pw.Widget> buildBody(DeliveryModel itemModel, {pw.Font? font,Uint8List?logoUint8List}) {
    final totalPrice = itemModel.items.fold<double>(
      0.0,
          (sum, it) => sum + (it.quantity * it.price),
    );
    final itemsCount = itemModel.items.length;

    // نعرض أول 3 عناصر فقط في الملخص
    final visibleItems = itemModel.items.take(3).toList();
    final remaining = itemsCount - visibleItems.length;

    final barcodeWidget = pw.BarcodeWidget(
      data: itemModel.orderId,
      barcode: Barcode.code128(),
      width: double.infinity,
      height: 60,
      drawText: false,
    );

    final qrWidget = pw.BarcodeWidget(
      data: itemModel.orderId,
      barcode: Barcode.qrCode(),
      width: 60,
      height: 60,
    );

    return [
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          borderRadius: pw.BorderRadius.circular(10),
          border: pw.Border.all(color: PdfColors.grey600, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            // شريط علوي باسم المتجر
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child:pw.Row(
                mainAxisSize: pw.MainAxisSize.max,
                 mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(logoUint8List!=null)
                    pw.Container(
                      height: 45,
                      width: 45,
                      alignment: pw.Alignment.center,
                      child: pw.Image(
                        pw.MemoryImage(logoUint8List),
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  pw.Spacer(),
                  pw.Center(
                    child: pw.Text(
                      'برج العرب للهواتف',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                        font: font,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ),
                  pw.Spacer(),

                ]
              )
            ),

            pw.SizedBox(height: 8),

            // مرسل إليه (كبير)
            _toBox(
              nameAndPhone: '${itemModel.recipientName} - ${itemModel.phone}',
              address: itemModel.address,
              font: font,
            ),

            pw.SizedBox(height: 8),

            // مرسل (صغير)
            _fromBox(
              storeName: 'المرسل: برج العرب للهواتف',
              font: font,
            ),

            pw.SizedBox(height: 8),

            // ميتاداتا الطلب على شكل Tags
            pw.Wrap(
              alignment: pw.WrapAlignment.end,
              spacing: 6,
              runSpacing: 6,
              children: [
                _metaTag('رقم الطلب', itemModel.orderId, font),
                _metaTag('تاريخ التوصيل',
                    itemModel.orderDate.add(const Duration(days: 1)).dayMonthYear, font),
                _metaTag('عدد العناصر', '$itemsCount', font),
                _metaTag('الإجمالي', totalPrice.toStringAsFixed(2), font),
              ],
            ),

            pw.SizedBox(height: 8),

            // ملخص العناصر (مختصر)
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'تفاصيل العناصر',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      font: font,
                    ),
                    textDirection: pw.TextDirection.rtl,
                  ),
                  pw.SizedBox(height: 4),
                  ...visibleItems.map(
                        (it) => pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          // السعر × الكمية
                          (it.price * it.quantity).toStringAsFixed(2),
                          style: pw.TextStyle(fontSize: 8, font: font),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.Text(
                          'x${it.quantity}',
                          style: pw.TextStyle(
                            fontSize: 8,
                            font: font,
                            color: PdfColors.grey700,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                        pw.SizedBox(width: 6),
                        pw.Expanded(
                          child: pw.Text(
                            it.name,
                            maxLines: 1,
                            overflow: pw.TextOverflow.clip,
                            style: pw.TextStyle(fontSize: 8, font: font),
                            textDirection: pw.TextDirection.rtl,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (remaining > 0)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 2),
                      child: pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          'و +$remaining عناصر أخرى…',
                          style: pw.TextStyle(
                            fontSize: 8,
                            font: font,
                            color: PdfColors.grey700,
                          ),
                          textDirection: pw.TextDirection.rtl,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            pw.SizedBox(height: 10),

            // باركود عريض + QR صغير
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      barcodeWidget,
                      pw.SizedBox(height: 4),
                      pw.Center(
                        child: pw.Text(
                          itemModel.orderId,
                          style: pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                            font: font,
                          ),
                          textDirection: pw.TextDirection.ltr, // رقم الطلب كما هو
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Container(
                  width: 70,
                  child: qrWidget,
                ),
              ],
            ),
          ],
        ),
      ),
    ];
  }

  @override
  pw.Widget buildFooter() => pw.SizedBox();

  // ======================= Helpers =======================

  pw.Widget _toBox({
    required String nameAndPhone,
    required String address,
    pw.Font? font,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text(
            'مرسل إليه',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            nameAndPhone,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            address,
            style: pw.TextStyle(fontSize: 9, font: font),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  pw.Widget _fromBox({
    required String storeName,
    pw.Font? font,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          // ملاحظة فارغة حالياً (يمكن تعبئتها لاحقاً "قابل للكسر" مثلاً)
          pw.Text(
            '+97168666411',
            style: pw.TextStyle(fontSize: 9, font: font),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.Text(
            storeName,
            style: pw.TextStyle(
              fontSize: 9,
              font: font,
              color: PdfColors.grey700,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  pw.Widget _metaTag(String label, String value, pw.Font? font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey200,
        borderRadius: pw.BorderRadius.circular(6),
        border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
      ),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              font: font,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
          pw.SizedBox(width: 4),
          pw.Text(
            '$label:',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey700,
              font: font,
            ),
            textDirection: pw.TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}