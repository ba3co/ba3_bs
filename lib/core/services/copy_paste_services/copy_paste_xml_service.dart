import 'package:ba3_bs/core/utils/app_ui_utils.dart';
import 'package:ba3_bs/features/materials/data/models/materials/material_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';

import '../../../features/bill/data/models/invoice_record_model.dart';
import '../../helper/win23_helpers/clipboard_custom128.dart';


class ClipboardXmlService {

  Future<void> copy(List<MaterialModel> items) async {
    final builder = XmlBuilder();

    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('Lines', nest: () {
      for (var item in items) {
        builder.element('Line', nest: () {
          builder.text(item.toXml());
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
        builder.element('Line', nest: () {
          builder.text(item.toXml());
        });
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

  Future<List<InvoiceRecordModel>?> paste() async {
    final clipboard = await Clipboard.getData('text/plain');
    if (clipboard?.text == null) return null;

    final sanitized = sanitizeXml(clipboard!.text!);

    try {
      return parseXmlTolerant(sanitized);
    } catch (e, st) {
      debugPrint('Paste failed: $e\n$st');
      AppUIUtils.onFailure('Paste failed: $e\n$st');
      return null;
    }
  }

  List<InvoiceRecordModel> parseXmlTolerant(String xmlString) {
    final doc = XmlDocument.parse(xmlString);
    final result = <InvoiceRecordModel>[];

    for (final line in doc.findAllElements('Line')) {
      try {
        final escapedMatRecXml = line.innerText.trim();
        if (escapedMatRecXml.isEmpty) continue;

        // Decode &lt; &gt; &amp; etc
        final decodedXml = escapedMatRecXml
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&amp;', '&');

        // Parse decoded XML
        final matRecDoc = XmlDocument.parse(decodedXml);
        final matRec = matRecDoc.findAllElements('MatRec').first;

        result.add(
          InvoiceRecordModel.fromXml(matRec.toXmlString()),
        );
      } catch (e) {
        // tolerate broken lines
        debugPrint('Skipping broken Line: $e');
        continue;
      }
    }

    return result;
  }

}

