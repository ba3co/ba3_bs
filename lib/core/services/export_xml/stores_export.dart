import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../helper/enums/enums.dart';

class StoresExport {

  xml.XmlElement exportStores(List<StoreAccount> stores) {
    final storeElements = <xml.XmlNode>[
      xml.XmlElement(xml.XmlName('StoresCount'), [], [xml.XmlText(stores.length.toStringAsFixed(2))]),
      ...stores.map((s) => xml.XmlElement(xml.XmlName('S'), [], [
        XmlHelpers.element('sptr', s.typeGuide),
        XmlHelpers.element('StoreCode', s == StoreAccount.main ? '1' : '0'), // أو حسب ما يناسبك
        XmlHelpers.element('StoreName', s.value),
        XmlHelpers.element('StoreLatinName', null),
        XmlHelpers.element('StoreParentGuid', '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('StoreAcc', '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('StoreAddress', null),
        XmlHelpers.element('StoreKeeper', null),
        XmlHelpers.element('StoreBranchMask', '0'),
        XmlHelpers.element('StoreSecurity', '1'),
      ])),
    ];

    return xml.XmlElement(xml.XmlName('Stores'), [], storeElements);
  }
}