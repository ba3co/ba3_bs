import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/json_import_service_base.dart';
import '../../data/models/bill_model.dart';

class BillJsonImport extends JsonImportServiceBase<BillModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Bill'] ?? [];

    List<BillModel> sss =
        billsJson.map((billJson) => BillModel.fromImportedJsonFile(billJson as Map<String, dynamic>)).toList();

    return sss;
  }

  @override
  List<BillModel> fromImportXml(XmlDocument document) {
    final billsXml = document.findAllElements('Bill');

    List<BillModel> bills = billsXml.map((billElement) {
      Map<String, dynamic> billJson = {
        'B': {
          'BillTypeGuid': billElement.findElements('B').single.findElements('BillTypeGuid').single.text,
          'BillGuid': billElement.findElements('B').single.findElements('BillGuid').single.text,
          'BillBranch': billElement.findElements('B').single.findElements('BillBranch').single.text,
          'BillPayType': billElement.findElements('B').single.findElements('BillPayType').single.text,
          'BillCheckTypeGuid': billElement.findElements('B').single.findElements('BillCheckTypeGuid').single.text,
          'BillNumber': billElement.findElements('B').single.findElements('BillNumber').single.text,
          'BillCustPtr': billElement.findElements('B').single.findElements('BillCustPtr').single.text,
          'BillCustName': billElement.findElements('B').single.findElements('BillCustName').single.text,
          'BillCurrencyGuid': billElement.findElements('B').single.findElements('BillCurrencyGuid').single.text,
          'BillCurrencyVal': billElement.findElements('B').single.findElements('BillCurrencyVal').single.text,
          'BillDate': billElement.findElements('B').single.findElements('BillDate').single.text,
          'BillStoreGuid': billElement.findElements('B').single.findElements('BillStoreGuid').single.text,
          'Note': billElement.findElements('B').single.findElements('Note').single.text,
          'BillCustAcc': billElement.findElements('B').single.findElements('BillCustAcc').single.text,
          'BillMatAccGuid': billElement.findElements('B').single.findElements('BillMatAccGuid').single.text,
          'BillCostGuid': billElement.findElements('B').single.findElements('BillCostGuid').single.text,
          'BillVendorSalesMan': billElement.findElements('B').single.findElements('BillVendorSalesMan').single.text,
          'BillFirstPay': billElement.findElements('B').single.findElements('BillFirstPay').single.text,
          'BillFPayAccGuid': billElement.findElements('B').single.findElements('BillFPayAccGuid').single.text,
          'BillSecurity': billElement.findElements('B').single.findElements('BillSecurity').single.text,
          'BillTransferGuid': billElement.findElements('B').single.findElements('BillTransferGuid').single.text,
          'BillFld1': billElement.findElements('B').single.findElements('BillFld1').single.text,
          'BillFld2': billElement.findElements('B').single.findElements('BillFld2').single.text,
          'BillFld3': billElement.findElements('B').single.findElements('BillFld3').single.text,
          'BillFld4': billElement.findElements('B').single.findElements('BillFld4').single.text,
          'ItemsDiscAcc': billElement.findElements('B').single.findElements('ItemsDiscAcc').single.text,
          'ItemsExtraAccGUID': billElement.findElements('B').single.findElements('ItemsExtraAccGUID').single.text,
          'CostAccGUID': billElement.findElements('B').single.findElements('CostAccGUID').single.text,
          'StockAccGUID': billElement.findElements('B').single.findElements('StockAccGUID').single.text,
          'BonusAccGUID': billElement.findElements('B').single.findElements('BonusAccGUID').single.text,
          'BonusContraAccGUID': billElement.findElements('B').single.findElements('BonusContraAccGUID').single.text,
          'VATAccGUID': billElement.findElements('B').single.findElements('VATAccGUID').single.text,
          'DIscCard': billElement.findElements('B').single.findElements('DIscCard').single.text,
          'BillAddressGUID': billElement.findElements('B').single.findElements('BillAddressGUID').single.text,
        }
      };

      final itemsElement = billElement.findElements('Items').single;
      final itemsJson = itemsElement.findElements('I').map((iElement) {
        return {
          'MatPtr': iElement.findElements('MatPtr').single.text,
          'QtyBonus': iElement.findElements('QtyBonus').single.text,
          'Unit': iElement.findElements('Unit').single.text,
          'PriceDescExtra': iElement.findElements('PriceDescExtra').single.text,
          'StorePtr': iElement.findElements('StorePtr').single.text,
          'Note': iElement.findElements('Note').single.text,
          'BonusDisc': iElement.findElements('BonusDisc').single.text,
          'UlQty': iElement.findElements('UlQty').single.text,
          'CostPtr': iElement.findElements('CostPtr').single.text,
          'ClassPtr': iElement.findElements('ClassPtr').single.text,
          'ClassPrice': iElement.findElements('ClassPrice').single.text,
          'ExpireProdDate': iElement.findElements('ExpireProdDate').single.text,
          'LengthWidthHeight': iElement.findElements('LengthWidthHeight').single.text,
          'Guid': iElement.findElements('Guid').single.text,
          'VatRatio': iElement.findElements('VatRatio').single.text,
          'SoGuid': iElement.findElements('SoGuid').single.text,
          'SoType': iElement.findElements('SoType').single.text,
        };
      }).toList();

      billJson['Items'] = {"I": itemsJson};
      return BillModel.fromImportedJsonFile(billJson);
    }).toList();

    return bills;
  }
}
