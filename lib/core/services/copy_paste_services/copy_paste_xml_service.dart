import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../../helper/win23_helpers/clipboard_custom128.dart';


class ClipboardXmlService {

  Future<void> copy(List<MaterialModel> items) async {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('Lines', nest: () {
      for (var item in items) {
        builder.element('Line', nest: () {
          item.toXml(builder);
        });
      }
    });

    final xml = builder.buildDocument().toXmlString(pretty: true, indent: '  ');

    await Clipboard.setData(ClipboardData(text: xml));
  }


  Future<void> copyXmlWithCustom128(List<MaterialModel> items) async {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('Lines', nest: () {
      for (var item in items) {
        builder.element('Line', nest: () => item.toXml(builder));
      }
    });

    final xml = builder.buildDocument().toXmlString(pretty: true, indent: '  ');

    // 1️⃣ Copy as normal text
    await Clipboard.setData(ClipboardData(text: xml));

    // 2️⃣ Attach custom 128 format
    final bytes = Uint8List.fromList([
      0x00, 0x10, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00,
      0x01, 0x00, 0x00, 0x00,
      0x1C, 0x0D, 0xDE, 0x15
    ]);
    setClipboardCustom128(bytes);
  }



// -------------------------------------------------------------
//  CLEANER: Removes invisible characters, BOM, duplicate <?xml>
// -------------------------------------------------------------
  String sanitizeXml(String input) {
    String cleaned = input

    // Remove BOM, NULL, control chars
        .replaceAll(RegExp(r'[\u0000-\u001F\uFEFF]'), '')

    // Remove ZERO WIDTH chars
        .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060-\u206F]'), '')

    // Remove duplicate XML headers if present
        .replaceAll(RegExp(r'<\?xml[^>]*\?>'), '')

        .trim();

    // Ensure begins at first tag
    int idx = cleaned.indexOf('<');
    if (idx > 0) cleaned = cleaned.substring(idx);

    // Wrap if XML is missing a single root
    if (!cleaned.trim().startsWith('<Root>')) {
      cleaned = '<Root>$cleaned</Root>';
    }

    return cleaned;
  }

// -------------------------------------------------------------
//  PASTE FUNCTION (sanitizes, parses safely, returns list)
// -------------------------------------------------------------
  Future<List<MaterialModel>?> paste() async {
    final clipboard = await Clipboard.getData('text/plain');
    if (clipboard == null || clipboard.text == null) return null;

    String text = sanitizeXml(clipboard.text!);

    debugPrint("SANITIZED XML:\n$text");

    try {

      var mats= parseXmlTolerant(text);
      return mats;

    } catch (e) {
      debugPrint("FINAL XML PARSE FAILURE: $e");
      return null;
    }
  }


// -------------------------------------------------------------
//  TOLERANT PARSER — extracts all <MatRec> no matter structure
// -------------------------------------------------------------

  List<MaterialModel> parseXmlTolerant(String xmlString) {
    final document = XmlDocument.parse(xmlString);

    final recs = <MaterialModel>[];

    final lines = document.findAllElements('Line');

    for (final line in lines) {
      final matRec = line.getElement('MatRec');
      if (matRec == null) continue;


      final mat = MaterialModel(
        matName: matRec.getElement('Name')?.innerText,

        matCode: _parseIntFromDecimal(
            matRec.getElement('Code')?.innerText),
        matQuantity: _parseIntFromDecimal(
            matRec.getElement('Quantity')?.innerText),
        matBonus: _parseIntFromDecimal(
            matRec.getElement('CurBonus')?.innerText),
        matDefUnit: _parseIntFromDecimal(
            matRec.getElement('CurUnit')?.innerText),
        matUnit2FactFlag: _parseIntFromDecimal(
            matRec.getElement('CurUnitFact')?.innerText),
        matVAT: _parseDouble(
            matRec.getElement('Vat')?.innerText),

        matCurrencyVal: _parseDouble(
            matRec.getElement('CurVal')?.innerText),
        matLastPriceCurVal: _parseDouble(
            matRec.getElement('Profit')?.innerText),
        calcMinPrice: _parseDouble(
            matRec.getElement('UnitPrice')?.innerText),

        matUnity: matRec.getElement('UnityName')?.innerText,
        matNewGUID: matRec.getElement('MatPtr')?.innerText,
        matCompositionName:
        matRec.getElement('CompositionName')?.innerText,
        matVatGuid:
        matRec.getElement('BillCurrencyGuid')?.innerText,
      );

      recs.add(mat);
    }

    return recs;
  }


  int? _parseIntFromDecimal(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return double.tryParse(text)?.toInt();
  }

  double? _parseDouble(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return double.tryParse(text);
  }



}

