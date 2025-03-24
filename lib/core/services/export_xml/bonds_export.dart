import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/bond/data/models/bond_model.dart';

class BondsExport {
  /// Generates the Pay section of the export XML
  xml.XmlElement exportBonds(List<BondModel> bonds) {
    final accountElements = <xml.XmlNode>[
      xml.XmlElement(xml.XmlName('PayCount'), [], [xml.XmlText(bonds.length.toStringAsFixed(2))]),
      ...bonds.map((bond) => _buildBondElement(bond)),
    ];

    return xml.XmlElement(xml.XmlName('Pay'), [], accountElements);
  }

  xml.XmlElement _buildBondElement(BondModel bond) {
    final items = bond.payItems.itemList.map((item) {
      return xml.XmlElement(
        xml.XmlName('N'),
        [],
        [
          XmlHelpers.element('EntryAccountGuid', item.entryAccountGuid),
          XmlHelpers.element('EntryDate', item.entryDate),
          XmlHelpers.element('EntryDebit', item.entryDebit?.toString() ?? '0'),
          XmlHelpers.element('EntryCredit', item.entryCredit?.toString() ?? '0'),
          XmlHelpers.element('EntryNote', item.entryNote),
          XmlHelpers.element('EntryCurrencyGuid', item.entryCurrencyGuid),
          XmlHelpers.element('EntryCurrencyVal', item.entryCurrencyVal?.toString() ?? '1'),
          XmlHelpers.element('EntryCostGuid', item.entryCostGuid),
          XmlHelpers.element('EntryClass', item.entryClass),
          XmlHelpers.element('EntryNumber', item.entryNumber?.toString() ?? '0'),
          XmlHelpers.element('EntryCustomerGuid', item.entryCustomerGuid),
          XmlHelpers.element('EntryType', item.entryType?.toString() ?? '0'),
        ],
      );
    }).toList();

    return xml.XmlElement(
      xml.XmlName('P'),
      [],
      [
        XmlHelpers.element('PayTypeGuid', bond.payTypeGuid),
        XmlHelpers.element('PayNumber', bond.payNumber?.toString() ?? '0'),
        XmlHelpers.element('PayGuid', bond.payGuid),
        XmlHelpers.element('PayBranchGuid', bond.payBranchGuid),
        XmlHelpers.element('PayDate', bond.payDate),
        XmlHelpers.element('EntryPostDate', bond.entryPostDate),
        XmlHelpers.element('PayNote', bond.payNote),
        XmlHelpers.element('PayCurrencyGuid', bond.payCurrencyGuid),
        XmlHelpers.element('PayCurVal', bond.payCurVal?.toString() ?? '1'),
        XmlHelpers.element('PayAccountGuid', bond.payAccountGuid),
        XmlHelpers.element('PaySecurity', bond.paySecurity?.toString() ?? '1'),
        XmlHelpers.element('PaySkip', bond.paySkip?.toString() ?? '0'),
        XmlHelpers.element('ErParentType', bond.erParentType?.toString() ?? '4'),
        xml.XmlElement(xml.XmlName('PayItems'), [], items),
        XmlHelpers.element('E', bond.e ?? 'E=2'),
      ],
    );
  }


}