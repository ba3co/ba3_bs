import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/cheques/data/models/cheques_model.dart';

class ChequesExport {

  /// Generates the Chk section of the export XML
   xml.XmlElement exportChecks(List<ChequesModel> cheques) {
    final cEntryGuid =  XmlHelpers.uuid.v4();

    return xml.XmlElement(
        xml.XmlName('Checks'),
        [],
        cheques.map((chq) {
          return xml.XmlElement(xml.XmlName('H'), [], [
            XmlHelpers.element('CheckTypeGuid', chq.chequesTypeGuid),
            XmlHelpers.element('CheckNumber', chq.chequesNumber?.toString()),
            XmlHelpers.element('CheckNum', chq.chequesNum?.toString()),
            XmlHelpers.element('CheckParentGuid', '00000000-0000-0000-0000-000000000000'),
            XmlHelpers.element('CheckGuid', chq.chequesGuid),
            XmlHelpers.element('CheckBrGuid', '00000000-0000-0000-0000-000000000000'),
            XmlHelpers.element('CheckDir', '2'),
            XmlHelpers.element('AccPtr', chq.accPtr),
            XmlHelpers.element('CheckDate', chq.chequesDate),
            XmlHelpers.element('CheckDueDate', chq.chequesDueDate),
            XmlHelpers.element('CheckColDate', '1-1-1980'),
            XmlHelpers.element('CheckBankGuid', '00000000-0000-0000-0000-000000000000'),
            XmlHelpers.element('CheckNote', chq.chequesNote),
            XmlHelpers.element('CheckVal', chq.chequesVal?.toString() ?? '0'),
            XmlHelpers.element('CheckCurGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
            XmlHelpers.element('CheckCurVal', '1'),
            XmlHelpers.element('CheckSec', '1'),
            XmlHelpers.element('CheckPrevNum', '0'),
            XmlHelpers.element('CheckOrgName', null),
            XmlHelpers.element('CheckIntNum', null),
            XmlHelpers.element('CheckIntFile', null),
            XmlHelpers.element('CheckExtFile', null),
            XmlHelpers.element('CheckFileDate', chq.chequesDate),
            XmlHelpers.element('CheckCost1Guid', '00000000-0000-0000-0000-000000000000'),
            XmlHelpers.element('CheckCost2Guid', '00000000-0000-0000-0000-000000000000'),
            XmlHelpers.element('CheckAccount2Guid', chq.chequesAccount2Guid),
            XmlHelpers.element('CheckState', chq.isPayed == true ? '1' : '0'),
            XmlHelpers.element('CheckCustomerGuid', null), // خصصه لو لديك قيمة

            if (chq.isPayed == true) ...[
              _buildCheckCollectEntry(chq, cEntryGuid),
              _buildCheckEntryRelation(chq, cEntryGuid),
            ],
          ]);
        }).toList());
  }

  static xml.XmlElement _buildCheckCollectEntry(ChequesModel chq, String entryGuid) {
    return xml.XmlElement(xml.XmlName('CheckCollectEntry'), [], [
      xml.XmlElement(xml.XmlName('W'), [], [
        XmlHelpers.element('CEntryType', '1'),
        XmlHelpers.element('CEntryTypeGuid', chq.chequesTypeGuid),
        XmlHelpers.element('CEntryGuid', entryGuid),
        XmlHelpers.element('CEntryDate', chq.chequesPayDate),
        XmlHelpers.element('CEntryPostDate', chq.chequesPayDate),
        XmlHelpers.element('CEntryDebit', chq.chequesVal?.toString() ?? '0'),
        XmlHelpers.element('CEntryCredit', chq.chequesVal?.toString() ?? '0'),
        XmlHelpers.element('CEntryNote', chq.chequesNote),
        XmlHelpers.element('CEntryCurrencyGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
        XmlHelpers.element('CEntryCurrencyVal', '1'),
        XmlHelpers.element('CEntryIsPosted', '1'),
        XmlHelpers.element('CEntryState', '0'),
        XmlHelpers.element('CEntrySecurity', '1'),
        XmlHelpers.element('CEntryBranch', '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('CEntryNumber', '0'),
        // يمكن بناء PayItems حقيقية لاحقًا
        xml.XmlElement(xml.XmlName('PayItems'), [], [
          xml.XmlElement(xml.XmlName('N'), [], [
            XmlHelpers.element('EntryAccountGuid', chq.chequesAccount2Guid),
            XmlHelpers.element('EntryDate', chq.chequesPayDate),
            XmlHelpers.element('EntryDebit', chq.chequesVal?.toString() ?? '0'),
            XmlHelpers.element('EntryCredit', '0'),
            XmlHelpers.element('EntryNote', chq.chequesNote),
            XmlHelpers.element('EntryCurrencyGuid', '884edcde-c172-490d-a2f2-f10a0b90326a'),
            XmlHelpers.element('EntryCurrencyVal', '1'),
            XmlHelpers.element('EntryCostGuid', '00000000-0000-0000-0000-000000000000'),
            XmlHelpers.element('EntryClass', chq.chequesNum?.toString()),
            XmlHelpers.element('EntryNumber', '0'),
            XmlHelpers.element('EntryCustomerGuid', '00000000-0000-0000-0000-000000000000'),
            XmlHelpers.element('EntryType', '0'),
          ]),
        ]),
      ]),
      XmlHelpers.element('EntryCount', '1.00'),
    ]);
  }

 static xml.XmlElement _buildCheckEntryRelation(ChequesModel chq, String entryGuid) {
    final erGuid =  XmlHelpers.uuid.v4();

    return xml.XmlElement(xml.XmlName('CheckEntryRelation'), [], [
      xml.XmlElement(xml.XmlName('Rel'), [], [
        XmlHelpers.element('ErGUID', erGuid),
        XmlHelpers.element('ErEntryGUID', entryGuid),
        XmlHelpers.element('ErParentGUID', chq.chequesGuid),
        XmlHelpers.element('ErParentType', '6'),
        XmlHelpers.element('ErParentNumber', chq.chequesNumber?.toString() ?? '1'),
      ]),
    ]);
  }


}