import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/materials/data/models/materials/material_group.dart';

class GroupsExport {
  xml.XmlElement exportGroups(List<MaterialGroupModel> groups) {
    final groupElements = <xml.XmlNode>[
      xml.XmlElement(xml.XmlName('GroupsCount'), [], [xml.XmlText(groups.length.toStringAsFixed(2))]),
      ...groups.map((g) => xml.XmlElement(xml.XmlName('G'), [], [
        XmlHelpers.element('gPtr', g.matGroupGuid),
        XmlHelpers.element('GroupCode', g.groupCode),
        XmlHelpers.element('GroupName', g.groupName),
        XmlHelpers.element('GroupLatinName', g.groupLatinName),
        XmlHelpers.element('ParentGuid', g.parentGuid),
        XmlHelpers.element('GroupNotes', g.groupNotes),
        XmlHelpers.element('GroupSecurity', g.groupSecurity.toString()),
        XmlHelpers.element('GroupType', g.groupType.toString()),
        XmlHelpers.element('GroupVat', g.groupVat.toStringAsFixed(2)),
        XmlHelpers.element('GroupNumber', g.groupNumber.toString()),
        XmlHelpers.element('GroupBranchMask', g.groupBranchMask.toString()),
      ]))
    ];

    return xml.XmlElement(xml.XmlName('Groups'), [], groupElements);
  }
}