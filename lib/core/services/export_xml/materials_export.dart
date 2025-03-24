import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/materials/data/models/materials/material_model.dart';

class MaterialsExport {
  /// Generates the Materials section of the export XML
  xml.XmlElement exportMaterials(List<MaterialModel> materials) {
    return xml.XmlElement(
      xml.XmlName('Materials'),
      [],
      materials.map((mat) => _buildMaterialElement(mat)).toList(),
    );
  }

  xml.XmlElement _buildMaterialElement(MaterialModel mat) {
    return xml.XmlElement(
      xml.XmlName('M'),
      [],
      [
        XmlHelpers.element('mptr', mat.id),
        XmlHelpers.element('MatCode', mat.matCode?.toString()),
        XmlHelpers.element('MatName', mat.matName),
        XmlHelpers.element('MatBarCode', mat.matBarCode),
        XmlHelpers.element('MatGroupGuid', mat.matGroupGuid),
        XmlHelpers.element('MatUnity', mat.matUnity),
        XmlHelpers.element('MatPriceType', mat.matPriceType?.toString()),
        XmlHelpers.element('MatBonus', mat.matBonus?.toString() ?? '0'),
        XmlHelpers.element('MatBonusOne', mat.matBonusOne?.toString() ?? '1'),
        XmlHelpers.element('MatCurrencyGuid', mat.matCurrencyGuid),
        XmlHelpers.element('MatCurrencyVal', mat.matCurrencyVal?.toString() ?? '1'),
        XmlHelpers.element('MatPictureGuid', mat.matPictureGuid ?? '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('MatType', mat.matType?.toString() ?? '0'),
        XmlHelpers.element('MatSecurity', mat.matSecurity?.toString() ?? '1'),
        XmlHelpers.element('MatFlag', mat.matFlag?.toString() ?? '0'),
        XmlHelpers.element('MatExpireFlag', mat.matExpireFlag?.toString() ?? '0'),
        XmlHelpers.element('MatProdFlag', mat.matProdFlag?.toString() ?? '0'),
        XmlHelpers.element('MatSNFlag', mat.matSNFlag?.toString() ?? '-1'),
        XmlHelpers.element('MatVAT', mat.matVAT?.toString() ?? '0'),
        XmlHelpers.element('MatDefUnit', mat.matDefUnit?.toString() ?? '1'),
        XmlHelpers.element('MatCreateDate', mat.matCreateDate?.toIso8601String() ?? '1980-01-01T00:00:00'),
        XmlHelpers.element('MatFirstCostDate', mat.matFirstCostDate?.toIso8601String() ?? '1980-01-01T00:00:00'),
        XmlHelpers.element('MatPrevQty', mat.matPrevQty ?? '0.00'),
      ],
    );
  }
}