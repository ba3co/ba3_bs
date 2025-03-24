import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/sellers/data/models/seller_model.dart';

class CostsExport {
  xml.XmlElement exportCosts(List<SellerModel> sellers) {
    final costElements = <xml.XmlNode>[
      xml.XmlElement(xml.XmlName('CostCount'), [], [xml.XmlText(sellers.length.toStringAsFixed(2))]),
      ...sellers.map((s) => xml.XmlElement(xml.XmlName('Q'), [], [
        XmlHelpers.element('CostGuid', s.costGuid),
        XmlHelpers.element('CostCode', s.costCode?.toString()),
        XmlHelpers.element('CostName', s.costName),
        XmlHelpers.element('CostLatinName', s.costLatinName),
        XmlHelpers.element('CostParentGuid', s.costParentGuid ?? '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('CostNote', s.costNote),
        XmlHelpers.element('CostDebit', s.costDebit ?? '0.00'),
        XmlHelpers.element('CostCredit', s.costCredit ?? '0.00'),
        XmlHelpers.element('CostType', s.costType?.toStringAsFixed(2) ?? '0.00'),
        XmlHelpers.element('CostSecurity', s.costSecurity?.toStringAsFixed(2) ?? '1.00'),
        XmlHelpers.element('CostRes1', s.costRes1?.toStringAsFixed(2) ?? '0.00'),
        XmlHelpers.element('CostRes2', s.costRes2?.toStringAsFixed(2) ?? '0.00'),
        XmlHelpers.element('CostBranchMask', s.costBranchMask?.toString() ?? '0'),
        XmlHelpers.element('CostIsChangeableRatio', s.costIsChangeableRatio?.toStringAsFixed(2) ?? '0.00'),
      ]))
    ];

    return xml.XmlElement(xml.XmlName('Cost1'), [], costElements);
  }
}