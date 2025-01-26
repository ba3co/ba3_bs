
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/bill_model.dart';

class BillImport extends ImportServiceBase<BillModel> with FirestoreSequentialNumbers {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Bill'] ?? [];

    return billsJson.map((billJson) => BillModel.fromImportedJsonFile(billJson as Map<String, dynamic>)).toList();
  }

  late Map<String, int> billsNumbers;

  Future<void> initializeNumbers() async {
    billsNumbers = {
      for (var billType in BillType.values)
        billType.typeGuide: await getLastNumber(
          category: ApiConstants.bills,
          entityType: billType.label,
          // number: 0,
        )
    };
  }

  int getLastBillNumber(String billTypeGuid) {
    if (!billsNumbers.containsKey(billTypeGuid)) {
      throw Exception('Bill type not found');
    }
    billsNumbers[billTypeGuid] = billsNumbers[billTypeGuid]! + 1;
    return billsNumbers[billTypeGuid]!;
  }

  setLastNumber() async {
    billsNumbers.forEach(
      (billTypeGuid, number) async {
        await satNumber(ApiConstants.bills, BillType.byTypeGuide(billTypeGuid).label, number);
      },
    );
  }

  @override
  Future<List<BillModel>> fromImportXml(XmlDocument document) async {
    await initializeNumbers();
    final billsXml = document.findAllElements('Bill');
    final materialXml = document.findAllElements('M');

    Map<String, String> matNameWithId = {};

    for (var mat in materialXml) {
      String matGuid = mat.findElements('mptr').first.text;
      String amtName = mat.findElements('MatName').first.text;
      matNameWithId[matGuid] = amtName;
    }
   await Future.delayed(Durations.long4);
    // matNameWithId.forEach((key, value) => log('$value   $key'),);
    List<BillModel> bills = billsXml.map((billElement) {
      // String customerId =
      //     read<AccountsController>().getAccountIdByName(billElement.findElements('B').single.findElements('BillCustName').single.text);
      Map<String, dynamic> billJson = {
        'B': {
          'BillTypeGuid': billElement.findElements('B').single.findElements('BillTypeGuid').single.text,
          'BillGuid': billElement.findElements('B').single.findElements('BillGuid').single.text,
          'BillBranch': billElement.findElements('B').single.findElements('BillBranch').single.text,
          'BillPayType': billElement.findElements('B').single.findElements('BillPayType').single.text,
          'BillCheckTypeGuid': billElement.findElements('B').single.findElements('BillCheckTypeGuid').single.text,
          'BillNumber': getLastBillNumber(billElement
              .findElements('B')
              .single
              .findElements('BillTypeGuid')
              .single
              .text) /*billElement.findElements('B').single.findElements('BillNumber').single.text*/,
          'BillCustPtr': billElement.findElements('B').single.findElements('BillCustAcc').single.text,
          // 'BillCustPtr': customerId,
          'BillCustName':
              read<AccountsController>().getAccountNameById(billElement.findElements('B').single.findElements('BillCustAcc').single.text),
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
          'MatPtr': read<MaterialController>().getMaterialByName(matNameWithId[iElement.findElements('MatPtr').single.text])!.id,
          'MatName': matNameWithId[iElement.findElements('MatPtr').single.text],
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
    await setLastNumber();
    return bills;
  }
}
