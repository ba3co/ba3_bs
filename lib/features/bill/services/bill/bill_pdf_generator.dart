import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/extensions/basic/string_extension.dart';
import 'package:ba3_bs/core/helper/extensions/date_time/date_time_extensions.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/bill/data/models/bill_model.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../../../materials/controllers/material_controller.dart';

/// --------------------------------------------------------
///                   NewBillPdfGenerator
/// --------------------------------------------------------

class BillPdfGenerator extends PdfGeneratorBase<BillModel> {
  final _sellerController = read<SellersController>();
  final _materialController = read<MaterialController>();

  @override
  Widget buildHeader(BillModel itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBillDetails(itemModel, font),
        if (logoUint8List != null)
          Image(
            MemoryImage(logoUint8List),
            width: 5 * PdfPageFormat.cm,
            height: 5 * PdfPageFormat.cm,
          ),
      ],
    );
  }

  Widget _buildBillDetails(BillModel itemModel, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleText(AppStrings.newBill, 24, FontWeight.bold, font),
        _buildSpacing(),
        _buildDetailRow('Bill number: ', itemModel.billDetails.billNumber.toString()),
        _buildSpacing(),
        _buildDetailRow('Bill type: ', billName(itemModel), font, TextDirection.rtl),
        _buildSpacing(),
        _buildDetailRow('Bill id: ', itemModel.billId!),
        _buildSpacing(),
        _buildDetailRow('Date of Invoice: ', itemModel.billDetails.billDate!.dayMonthYear),
        _buildSpacing(),
        _buildDetailRow(
          'Seller Name: ',
          _sellerController.getSellerNameById(itemModel.billDetails.billSellerId),
          font,
          TextDirection.rtl,
        ),
        _buildSpacing(),
      ],
    );
  }

  Widget _buildTitleText(String text, double size, FontWeight weight, Font? font) {
    return Text(
      text,
      textDirection: TextDirection.rtl,
      style: TextStyle(fontSize: size, fontWeight: weight, font: font),
    );
  }

  Widget _buildDetailRow(String title, String value, [Font? font, TextDirection? direction]) {
    return Row(
      children: [
        Text(title),
        Text(
          value,
          style: font != null ? TextStyle(font: font) : null,
          textDirection: direction,
        ),
      ],
    );
  }

  Widget _buildSpacing() => SizedBox(height: 0.4 * PdfPageFormat.cm);

  @override
  List<Widget> buildBody(BillModel itemModel, {Font? font}) {
    final headers = ['Item Name', 'Barcode', 'Quantity', 'Unit Price', 'VAT', 'Total'];
    final data = _buildTableData(itemModel);

    return <Widget>[
      _buildTitleText('تفاصيل الفاتورة', 20, FontWeight.bold, font),
      TableHelper.fromTextArray(
        headers: headers,
        data: data,
        headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font),
        cellStyle: TextStyle(font: font),
        tableDirection: TextDirection.rtl,
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        columnWidths: _columnWidths,
        cellAlignments: _cellAlignments,
      ),
      Divider(),
      buildTotal(itemModel)
    ];
  }

  List<List<dynamic>> _buildTableData(BillModel itemModel) {
    return itemModel.items.itemList.map((item) {
      final barcodeWidget = _buildBarcode(item.itemGuid);

      return [
        item.itemName,
        barcodeWidget,
        '${item.itemQuantity}',
        (item.itemSubTotalPrice ?? 0).toStringAsFixed(2),
        (item.itemVatPrice ?? 0).toStringAsFixed(2),
        (item.itemTotalPrice.toDouble).toStringAsFixed(2),
      ];
    }).toList();
  }

  Widget _buildBarcode(String itemGuid) {
    final barcode = Barcode.code128();
    final barcodeData = _materialController.getMaterialBarcodeById(itemGuid);

    return BarcodeWidget(
      barcode: barcode,
      data: barcodeData,
      width: 100,
      height: 40,
    );
  }

  Map<int, TableColumnWidth> get _columnWidths => {
        0: const FixedColumnWidth(150), // Item Name
        1: const FixedColumnWidth(80), // Barcode
        2: const FixedColumnWidth(60), // Quantity
        3: const FixedColumnWidth(60), // Unit Price
        4: const FixedColumnWidth(50), // VAT
        5: const FixedColumnWidth(60), // Total
      };

  Map<int, Alignment> get _cellAlignments => {
        0: Alignment.centerLeft, // Item Name
        1: Alignment.center, // Barcode
        2: Alignment.center, // Quantity
        3: Alignment.center, // Unit Price
        4: Alignment.center, // VAT
        5: Alignment.center, // Total
      };

  Widget buildTotal(BillModel itemModel) {
    final vat = itemModel.billDetails.billVatTotal ?? 0;
    final totalBeforeVat = itemModel.billDetails.billBeforeVatTotal ?? 0;
    final netTotal = totalBeforeVat + vat;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        alignment: Alignment.centerRight,
        child: Row(
          children: [
            Spacer(flex: 6),
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTotalText('Net total', netTotal.toStringAsFixed(2)),
                  _buildTotalText('Vat 5.0 %', vat.toStringAsFixed(2)),
                  Divider(),
                  _buildTotalText(
                    'Total amount due',
                    netTotal.toStringAsFixed(2),
                    titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2 * PdfPageFormat.mm),
                  _buildGreyLine(),
                  SizedBox(height: 0.5 * PdfPageFormat.mm),
                  _buildGreyLine(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalText(
    String title,
    String value, {
    TextStyle? titleStyle,
    double width = double.infinity,
  }) {
    final style = titleStyle ?? TextStyle(fontWeight: FontWeight.bold);

    return Container(
      width: width,
      child: Row(
        children: [
          Expanded(child: Text(title, style: style)),
          Text(value, style: style),
        ],
      ),
    );
  }

  Widget _buildGreyLine() => Container(height: 1, color: PdfColors.grey400);

  String billName(BillModel billModel) => BillType.byLabel(billModel.billTypeModel.billTypeLabel!).value;
}

/// ------------------------------------------------------------------------
///                         UpdatedBillPdfGenerator
/// ------------------------------------------------------------------------

class BillComparisonPdfGenerator extends PdfGeneratorBase<List<BillModel>> {
  final _accountsController = read<AccountsController>();
  final _sellerController = read<SellersController>();
  final _materialController = read<MaterialController>();

  @override
  Widget buildHeader(List<BillModel> itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    final BillModel beforeUpdate = itemModel[0];
    //  final BillModel afterUpdate = itemModel[1];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildText(fileName, font: font),
            RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'الرقم التعريفي للفاتورة: ',
                    style: TextStyle(
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                  TextSpan(
                    text: beforeUpdate.billId,
                    style: TextStyle(
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                ],
              ),
            ),
            RichText(
              textDirection: TextDirection.rtl,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'رقم الفاتورة: ',
                    style: TextStyle(
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                  TextSpan(
                    text: beforeUpdate.billDetails.billNumber.toString(),
                    style: TextStyle(
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (logoUint8List != null)
          Image(
            MemoryImage(logoUint8List),
            width: 5 * PdfPageFormat.cm,
            height: 5 * PdfPageFormat.cm,
          ),
      ],
    );
  }

  Widget _buildText(
    String text, {
    TextDirection textDirection = TextDirection.rtl,
    double size = 24,
    FontWeight weight = FontWeight.bold,
    Font? font,
  }) {
    return Text(
      text,
      textDirection: textDirection,
      style: TextStyle(fontSize: size, fontWeight: weight, font: font),
    );
  }

  @override
  List<Widget> buildBody(List<BillModel> itemModel, {Font? font}) {
    final BillModel beforeUpdate = itemModel[0];
    final BillModel afterUpdate = itemModel[1];

    final headersComparison = ['Field', AppConstants.before, AppConstants.after];
    final dataComparison = _buildComparisonData(beforeUpdate, afterUpdate);

    final headersItems = [
      'Item Name',
      'Barcode',
      'Quantity (${AppConstants.before})',
      'Quantity (${AppConstants.after})',
      'Unit Price (${AppConstants.before})',
      'Unit Price (${AppConstants.after})',
      'VAT (${AppConstants.before})',
      'VAT (${AppConstants.after})',
      'Total (${AppConstants.before})',
      'Total (${AppConstants.after})'
    ];
    final dataItems = _buildItemsComparisonData(beforeUpdate, afterUpdate, font);

    return <Widget>[
      _buildText('تفاصيل التعديلات', size: 20, font: font),

      /// Table for seller, customer, and date
      TableHelper.fromTextArray(
        headers: headersComparison,
        data: dataComparison,
        headerDirection: TextDirection.rtl,
        headerStyle: TextStyle(fontWeight: FontWeight.bold, font: font),
        cellStyle: TextStyle(font: font),
        tableDirection: TextDirection.rtl,
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        columnWidths: _columnWidthsSummary,
        cellAlignments: _cellAlignmentsSummary,
      ),

      SizedBox(height: 20),

      /// Table for item details
      TableHelper.fromTextArray(
        headers: headersItems,
        data: dataItems,
        headerDirection: TextDirection.rtl,
        headerAlignments: _headerAlignmentsItems,
        headerStyle: TextStyle(
          fontWeight: FontWeight.bold,
          font: font,
          fontSize: 10,
        ),
        cellStyle: TextStyle(font: font, fontSize: 10),
        tableDirection: TextDirection.rtl,
        headerDecoration: const BoxDecoration(color: PdfColors.grey300),
        cellHeight: 30,
        columnWidths: _columnWidthsItems,
        cellAlignments: _cellAlignmentsItems,
      ),

      Divider(),

      _buildSummary(beforeUpdate, afterUpdate),
    ];
  }

  List<List<dynamic>> _buildItemsComparisonData(BillModel beforeUpdate, BillModel afterUpdate, Font? font) {
    // Create maps of items for easier lookup by item GUID
    final itemsBefore = {for (var item in beforeUpdate.items.itemList) item.itemGuid: item};
    final itemsAfter = {for (var item in afterUpdate.items.itemList) item.itemGuid: item};

    // Combine all GUIDs from both before and after updates
    final allGuids = {...itemsBefore.keys, ...itemsAfter.keys};

    return allGuids.map((guid) {
      final before = itemsBefore[guid];
      final after = itemsAfter[guid];

      return [
        _textCell(before?.itemName ?? after?.itemName, font),
        _buildBarcode(guid),
        before?.itemQuantity.toString() ?? '0',
        after?.itemQuantity.toString() ?? '0',
        before?.itemSubTotalPrice?.toStringAsFixed(2) ?? '0.00',
        after?.itemSubTotalPrice?.toStringAsFixed(2) ?? '0.00',
        before?.itemVatPrice?.toStringAsFixed(2) ?? '0.00',
        after?.itemVatPrice?.toStringAsFixed(2) ?? '0.00',
        before?.itemTotalPrice.toDouble.toStringAsFixed(2) ?? '0.00',
        after?.itemTotalPrice.toDouble.toStringAsFixed(2) ?? '0.00',
      ];
    }).toList();
  }

  Widget _textCell(String? value, Font? font) {
    final textValue = value ?? 'Unknown';

    // Detect Arabic and English characters
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');

    // Split the text into words
    final words = textValue.split(RegExp(r'\s+'));

    final spans = <InlineSpan>[];

    for (final word in words) {
      final containsArabic = arabicRegex.hasMatch(word);
      final textDirection = containsArabic ? TextDirection.rtl : TextDirection.ltr;

      spans.add(WidgetSpan(
        child: Directionality(
          textDirection: textDirection,
          child: Text(
            word,
            style: TextStyle(
              font: font,
              fontSize: 10,
            ),
          ),
        ),
      ));

      // Add a space after each word (except the last)
      if (word != words.last) {
        spans.add(const TextSpan(text: ' '));
      }
    }

    // Overall direction is set to LTR for consistent layout
    return RichText(
      text: TextSpan(children: spans),
      textDirection: TextDirection.ltr,
    );
  }

  Widget _buildBarcode(String itemGuid) {
    final barcode = Barcode.code128();
    final barcodeData = _materialController.getMaterialBarcodeById(itemGuid);

    return BarcodeWidget(
      barcode: barcode,
      data: barcodeData,
      width: 100,
      height: 40,
    );
  }

  Map<int, TableColumnWidth> get _columnWidthsSummary => {
        0: const FixedColumnWidth(80), // Field
        1: const FixedColumnWidth(150), // Before
        2: const FixedColumnWidth(150), // After
      };

  Map<int, Alignment> get _cellAlignmentsSummary => {
        0: Alignment.centerLeft,
        1: Alignment.center,
        2: Alignment.center,
      };

  Map<int, TableColumnWidth> get _columnWidthsItems => {
        0: const FixedColumnWidth(120), // Item Name
        1: const FixedColumnWidth(100), // Barcode
        2: const FixedColumnWidth(100), // Quantity (Before)
        3: const FixedColumnWidth(100), // Quantity (After)
        4: const FixedColumnWidth(90), // Unit Price (Before)
        5: const FixedColumnWidth(80), // Unit Price (After)
        6: const FixedColumnWidth(90), // VAT (Before)
        7: const FixedColumnWidth(80), // VAT (After)
        8: const FixedColumnWidth(90), // Total (Before)
        9: const FixedColumnWidth(80), // Total (After)
      };

  Map<int, Alignment> get _headerAlignmentsItems => {
        0: Alignment.topCenter, // Item Name
        1: Alignment.topCenter, // Barcode
        2: Alignment.topCenter, // Quantity (Before)
        3: Alignment.topCenter, // Quantity (After)
        4: Alignment.topCenter, // Unit Price (Before)
        5: Alignment.topCenter, // Unit Price (After)
        6: Alignment.topCenter, // VAT (Before)
        7: Alignment.topCenter, // VAT (After)
        8: Alignment.topCenter, // Total (Before)
        9: Alignment.topCenter, // Total (After)
      };

  Map<int, Alignment> get _cellAlignmentsItems => {
        0: Alignment.topCenter, // Item Name
        1: Alignment.center, // Barcode
        2: Alignment.center, // Quantity (Before)
        3: Alignment.center, // Quantity (After)
        4: Alignment.center, // Unit Price (Before)
        5: Alignment.center, // Unit Price (After)
        6: Alignment.center, // VAT (Before)
        7: Alignment.center, // VAT (After)
        8: Alignment.center, // Total (Before)
        9: Alignment.center, // Total (After)
      };

  List<List<dynamic>> _buildComparisonData(BillModel beforeUpdate, BillModel afterUpdate) {
    final beforeCustomerName = _accountsController.getAccountNameById(beforeUpdate.billDetails.billCustomerId);
    final afterCustomerName = _accountsController.getAccountNameById(afterUpdate.billDetails.billCustomerId);

    final beforeSellerName = _sellerController.getSellerNameById(beforeUpdate.billDetails.billSellerId);
    final afterSellerName = _sellerController.getSellerNameById(afterUpdate.billDetails.billSellerId);

    return [
      ['العميل', beforeCustomerName, afterCustomerName],
      ['البائع', beforeSellerName, afterSellerName],
      [
        'التاريخ',
        beforeUpdate.billDetails.billDate?.dayMonthYear ?? '',
        afterUpdate.billDetails.billDate?.dayMonthYear ?? ''
      ],
      // Add more comparisons as needed
    ];
  }

  Widget _buildSummary(BillModel beforeUpdate, BillModel afterUpdate) {
    final double beforeTotal = beforeUpdate.billDetails.billTotal ?? 0;
    final double afterTotal = afterUpdate.billDetails.billTotal ?? 0;

    return Container(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _buildSummaryRow('Total Before Update:', beforeTotal.toStringAsFixed(2)),
          _buildSummaryRow('Total After Update:', afterTotal.toStringAsFixed(2)),
          Divider(),
          _buildSummaryRow(
            'Difference:',
            (afterTotal - beforeTotal).toStringAsFixed(2),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String title, String value, {TextStyle? style}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: style ?? TextStyle()),
        Text(value, style: style ?? TextStyle()),
      ],
    );
  }
}
