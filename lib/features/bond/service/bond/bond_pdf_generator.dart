import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/helper/extensions/getx_controller_extensions.dart';
import '../../../../core/services/pdf_generator/implementations/pdf_generator_base.dart';
import '../../../accounts/controllers/accounts_controller.dart';
import '../../data/models/bond_model.dart';

class BondPdfGenerator extends PdfGeneratorBase<BondModel> {
  final _accountsController = read<AccountsController>();

  @override
  Widget buildHeader(BondModel itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildBondDetails(itemModel, fileName, font),
        if (logoUint8List != null)
          Image(
            MemoryImage(logoUint8List),
            width: 5 * PdfPageFormat.cm,
            height: 5 * PdfPageFormat.cm,
          ),
      ],
    );
  }

  Widget _buildBondDetails(BondModel itemModel, String fileName, Font? font) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleText(fileName, 24, FontWeight.bold),
        _buildSpacing(),
        _buildDetailRow('Bond number: ', itemModel.payNumber.toString()),
        _buildSpacing(),
        _buildDetailRow('Bond type: ', bondName(itemModel), font, TextDirection.rtl),
        _buildSpacing(),
        _buildDetailRow('Bond id: ', itemModel.payGuid!),
        _buildSpacing(),
        _buildDetailRow('Date of Bond: ', itemModel.payDate!),
        _buildSpacing(),
      ],
    );
  }

  Widget _buildTitleText(String text, double size, FontWeight weight) {
    return Text(
      text,
      style: TextStyle(fontSize: size, fontWeight: weight),
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
  List<Widget> buildBody(BondModel itemModel, {Font? font}) {
    final headers = ['id', 'account', 'debt', 'credit', 'nots'];
    final data = _buildTableData(itemModel);

    return <Widget>[
      Text(
        'تفاصيل السند',
        textDirection: TextDirection.rtl,
        style: font != null ? TextStyle(font: font) : null,
      ),
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
    ];
  }

  List<List<dynamic>> _buildTableData(BondModel itemModel) {
    return List.generate(itemModel.payItems.itemList.length, (index) {
      final item = itemModel.payItems.itemList[index];

      final accountName = _accountsController.getAccountNameById(item.entryAccountGuid);

      return [
        index,
        accountName,
        item.entryDebit,
        item.entryCredit,
        item.entryNote,
      ];
    });
  }

  Map<int, TableColumnWidth> get _columnWidths => {
        0: const FixedColumnWidth(50), // id
        1: const FixedColumnWidth(150), // account
        2: const FixedColumnWidth(60), // debt
        3: const FixedColumnWidth(60), // credit
        4: const FixedColumnWidth(50), // nots
      };

  Map<int, Alignment> get _cellAlignments => {
        0: Alignment.centerLeft, // id
        1: Alignment.center, // account
        2: Alignment.center, // debt
        3: Alignment.center, // credit
        4: Alignment.center, // nots
      };

  String bondName(BondModel bondModel) => BondType.byTypeGuide(bondModel.payTypeGuid!).value;
}

class BondComparisonPdfGenerator extends PdfGeneratorBase<List<BondModel>> {
  final _accountsController = read<AccountsController>();

  @override
  Widget buildHeader(List<BondModel> itemModel, String fileName, {Uint8List? logoUint8List, Font? font}) {
    final BondModel beforeUpdate = itemModel[0];

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
                    text: 'الرقم التعريفي السند: ',
                    style: TextStyle(
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                  TextSpan(
                    text: beforeUpdate.payGuid.toString(),
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
                    text: 'رقم السند: ',
                    style: TextStyle(
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                  TextSpan(
                    text: beforeUpdate.payNumber.toString(),
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
                    text: 'نوع السند: ',
                    style: TextStyle(
                      fontSize: 12,
                      font: font,
                    ),
                  ),
                  TextSpan(
                    text: BondType.byTypeGuide(beforeUpdate.payTypeGuid!).value,
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
  List<Widget> buildBody(List<BondModel> itemModel, {Font? font}) {
    final BondModel beforeUpdate = itemModel[0];
    final BondModel afterUpdate = itemModel[1];

    final headersComparison = ['Field', AppConstants.before, AppConstants.after];
    final dataComparison = _buildComparisonData(beforeUpdate, afterUpdate);

    final headersItems = [
      'الحساب (${AppConstants.before})',
      'الحساب (${AppConstants.after})',
      'مدين (${AppConstants.before})',
      'مدين (${AppConstants.after})',
      'دائن (${AppConstants.before})',
      'دائن (${AppConstants.after})',
      'البيان (${AppConstants.after})',
      'البيان (${AppConstants.after})',
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
    ];
  }

  List<List<dynamic>> _buildItemsComparisonData(BondModel beforeUpdate, BondModel afterUpdate, Font? font) {
    // Create maps of items for easier lookup by item GUID
    final itemsBefore = beforeUpdate.payItems.itemList.groupBy(
      (p0) => p0.entryAccountGuid,
    );
    final itemsAfter = afterUpdate.payItems.itemList.groupBy(
      (p0) => p0.entryAccountGuid,
    );

    // Combine all GUIDs from both before and after updates
    final allGuids = {...itemsBefore.keys, ...itemsAfter.keys};

    return allGuids.map((guid) {
      final before = itemsBefore[guid];
      final after = itemsAfter[guid];

      return [
        _textCell(before?.firstOrNull?.entryAccountName ?? '', font),
        _textCell(after?.firstOrNull?.entryAccountName ?? '', font),
        (before?.fold(
                  0.0,
                  (previousValue, element) => previousValue + element.entryDebit!,
                ) ??
                0)
            .toString(),
        (after?.fold(
                  0.0,
                  (previousValue, element) => previousValue + element.entryDebit!,
                ) ??
                0)
            .toString(),
        (before?.fold(
                  0.0,
                  (previousValue, element) => previousValue + element.entryCredit!,
                ) ??
                0)
            .toString(),
        (after?.fold(
                  0.0,
                  (previousValue, element) => previousValue + element.entryCredit!,
                ) ??
                0)
            .toString(),
        before?.firstOrNull?.entryNote ?? '',
        after?.firstOrNull?.entryNote ?? '',
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

  Map<int, TableColumnWidth> get _columnWidthsSummary => {
        0: const FixedColumnWidth(80), // Field
        1: const FixedColumnWidth(150), // Before
        2: const FixedColumnWidth(150), // After
      };

  Map<int, Alignment> get _cellAlignmentsSummary => {
        0: Alignment.center,
        1: Alignment.center,
        2: Alignment.center,
      };

  Map<int, TableColumnWidth> get _columnWidthsItems => {
        0: const FixedColumnWidth(120),
        1: const FixedColumnWidth(100),
        2: const FixedColumnWidth(100),
        3: const FixedColumnWidth(100),
        4: const FixedColumnWidth(100),
        5: const FixedColumnWidth(100),
        6: const FixedColumnWidth(90),
        7: const FixedColumnWidth(80),
      };

  Map<int, Alignment> get _headerAlignmentsItems => {
        0: Alignment.topCenter,
        1: Alignment.topCenter,
        2: Alignment.topCenter,
        3: Alignment.topCenter,
        4: Alignment.topCenter,
        5: Alignment.topCenter,
        6: Alignment.topCenter,
        7: Alignment.topCenter,
      };

  Map<int, Alignment> get _cellAlignmentsItems => {
        0: Alignment.topCenter,
        1: Alignment.topCenter,
        2: Alignment.topCenter,
        3: Alignment.topCenter,
        4: Alignment.topCenter,
        5: Alignment.topCenter,
        6: Alignment.topCenter,
        7: Alignment.topCenter,
      };

  List<List<dynamic>> _buildComparisonData(BondModel beforeUpdate, BondModel afterUpdate) {
    final beforeCustomerName = _accountsController.getAccountNameById(beforeUpdate.payAccountGuid);
    final afterCustomerName = _accountsController.getAccountNameById(afterUpdate.payAccountGuid);

    return [
      if (BondType.byTypeGuide(beforeUpdate.payTypeGuid!) == BondType.paymentVoucher ||
          BondType.byTypeGuide(beforeUpdate.payTypeGuid!) == BondType.receiptVoucher)
        ['الحساب', beforeCustomerName, afterCustomerName],
      ['التاريخ', beforeUpdate.payDate, afterUpdate.payDate],
      ['البيان', beforeUpdate.payNote ?? '', afterUpdate.payNote ?? ''],
      // Add more comparisons as needed
    ];
  }
}
