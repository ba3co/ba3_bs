import 'package:ba3_bs/features/materials/data/models/material_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class MaterialImport extends ImportServiceBase<MaterialModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<MaterialModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> materialsJson = jsonContent['Materials']['M'] ?? [];

    return materialsJson.map((materialJson) => MaterialModel.fromJson(materialJson as Map<String, dynamic>)).toList();
  }

  @override
  List<MaterialModel> fromImportXml(XmlDocument document) {
    final materialsXml = document.findAllElements('M');
    final materialsGccXml = document.findAllElements('GCCMaterialTax');
    List<GccMatTax> gcc = materialsGccXml.map(
      (gccMat) {
        String getText(String tagName) {
          final elements = gccMat.findElements(tagName);
          return elements.isEmpty ? '' : elements.first.text;
        }

        return GccMatTax(vat: getText('GCCMaterialTaxRatio'), guid: getText('GCCMaterialTaxMatGUID'));
      },
    ).toList();
    List<MaterialModel> materials = materialsXml.map((materialElement) {
      String? getText(String tagName) {
        final elements = materialElement.findElements(tagName);
        return elements.isEmpty ? null : elements.first.text;
      }

      int? getInt(String tagName) {
        final text = getText(tagName);
        return text == null ? null : double.parse(text.toString()).toInt();
      }

      double? getDouble(String tagName) {
        final text = getText(tagName);
        return text == null ? null : double.parse(text);
      }

      DateTime? getDate(String tagName) {
        final text = getText(tagName);
        return text == null ? null : DateTime.parse(text);
      }

      return MaterialModel(
        id: getText('mptr') ?? '',
        matCode: getInt('MatCode'),
        matName: getText('MatName') ?? '',
        matBarCode: getText('MatBarCode') ?? '',
        matGroupGuid: getText('MatGroupGuid') ?? '',
        matUnity: getText('MatUnity'),
        matPriceType: getInt('MatPriceType'),
        matBonus: getInt('MatBonus'),
        matBonusOne: getInt('MatBonusOne'),
        matCurrencyGuid: getText('MatCurrencyGuid') ?? '',
        matCurrencyVal: getDouble('MatCurrencyVal'),
        matPictureGuid: getText('MatPictureGuid') ?? '',
        matType: getInt('MatType'),
        matSecurity: getInt('MatSecurity'),
        matFlag: getInt('MatFlag'),
        matExpireFlag: getInt('MatExpireFlag'),
        matProdFlag: getInt('MatProdFlag'),
        matUnit2FactFlag: getInt('MatUnit2FactFlag'),
        matUnit3FactFlag: getInt('MatUnit3FactFlag'),
        matSNFlag: getInt('MatSNFlag'),
        matForceInSN: getInt('MatForceInSN'),
        matForceOutSN: getInt('MatForceOutSN'),
        matVAT: getInt('MatVAT'),
        matDefUnit: getInt('MatDefUnit'),
        matBranchMask: getInt('MatBranchMask'),
        matAss: getInt('MatAss'),
        matOldGUID: getText('MatOldGUID') ?? '',
        matNewGUID: getText('MatNewGUID') ?? '',
        matCalPriceFromDetail: getInt('MatCalPriceFromDetail'),
        matForceInExpire: getInt('MatForceInExpire'),
        matForceOutExpire: getInt('MatForceOutExpire'),
        matCreateDate: getDate('MatCreateDate'),
        matIsIntegerQuantity: getInt('MatIsIntegerQuantity'),
        matClassFlag: getInt('MatClassFlag'),
        matForceInClass: getInt('MatForceInClass'),
        matForceOutClass: getInt('MatForceOutClass'),
        matDisableLastPrice: getInt('MatDisableLastPrice'),
        matLastPriceCurVal: getDouble('MatLastPriceCurVal'),
        matPrevQty: getText('MatPrevQty') ?? '',
        matFirstCostDate: getDate('MatFirstCostDate'),
        matHasSegments: getInt('MatHasSegments'),
        matParent: getText('MatParent') ?? '',
        matIsCompositionUpdated: getInt('MatIsCompositionUpdated'),
        matInheritsParentSpecs: getInt('MatInheritsParentSpecs'),
        matCompositionName: getText('MatCompositionName'),
        matCompositionLatinName: getText('MatCompositionLatinName'),
        movedComposite: getInt('MovedComposite'),
        wholesalePrice: getText('Whole2') ?? '',
        retailPrice: getText('retail2') ?? '',
        endUserPrice: getText('EndUser2') ?? '',
        matVatGuid: getText('MatVatGuid'),
      );
    }).toList();

    return materials;
  }
}

class GccMatTax {
  final String vat;
  final String guid;

  GccMatTax({required this.vat, required this.guid});
}
