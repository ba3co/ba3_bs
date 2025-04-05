import 'dart:developer';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/encode_decode_text.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/customer/controllers/customers_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/bill_model.dart';
import '../../use_cases/convert_bills_to_linked_list_use_case.dart';
import '../../use_cases/divide_large_bill_use_case.dart';

class BillImport extends ImportServiceBase<BillModel>
    with FirestoreSequentialNumbers {
  final DivideLargeBillUseCase _divideLargeBillUseCase =
      DivideLargeBillUseCase();
  final ConvertBillsToLinkedListUseCase _convertBillsToLinkedListUseCase =
      ConvertBillsToLinkedListUseCase();

  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson =
        jsonContent['MainExp']['Export']['Bill'] ?? [];
    bool freeBill = false;
    return billsJson
        .map((billJson) => BillModel.fromImportedJsonFile(
            billJson as Map<String, dynamic>, freeBill))
        .toList();
  }

  late Map<String, int> billsNumbers;

  Future<void> _fetchBillsTypesNumbers() async {
    billsNumbers = {
      for (var billType in BillType.values)
        billType.typeGuide: await getLastNumber(
            category: ApiConstants.bills, entityType: billType.label)
    };
  }

  List<List<dynamic>> _splitItemsIntoChunks(List items, int maxItemsPerBill) =>
      items.chunkBy((maxItemsPerBill));

  int _getNextBillNumber(
      {required String billTypeGuid,
      required List<Map<String, dynamic>> items}) {
    if (!billsNumbers.containsKey(billTypeGuid)) {
      throw Exception('Bill type not found');
    }

    final chunks = _splitItemsIntoChunks(items, AppConstants.maxItemsPerBill);

    if (chunks.length > 1) {
      final lastBillNumber = billsNumbers[billTypeGuid];
      billsNumbers[billTypeGuid] = lastBillNumber! + chunks.length;
      return lastBillNumber + 1;
    }

    billsNumbers[billTypeGuid] = billsNumbers[billTypeGuid]! + 1;
    return billsNumbers[billTypeGuid]!;
  }

  _saveBillsTypesNumbers() async {
    billsNumbers.forEach(
      (billTypeGuid, number) async {
        await setLastUsedNumber(ApiConstants.bills,
            BillType.byTypeGuide(billTypeGuid).label, number);
      },
    );
  }

  /// Extracts order number from "رقم الطلب" or "TABBY-"
  String? _extractOrderNumber(String noteText) {
    // Remove unexpected characters
    noteText = noteText.trim();

    // Match "رقم الطلب" in different formats
    final orderMatch = RegExp(r'رقم\s?الطلب[\s\-=:]*([\d]+)', unicode: true)
        .firstMatch(noteText);
    if (orderMatch != null) {
      // log('Matched Order Number: ${orderMatch.group(1)}', name: 'Regex');
      return orderMatch.group(1);
    }

    // Match "TABBY-" or "tabby-" followed by numbers (case-insensitive)
    final tabbyMatch =
        RegExp(r'tabby-(\d+)', caseSensitive: false).firstMatch(noteText);
    if (tabbyMatch != null) {
      // log('Matched Tabby Order Number: ${tabbyMatch.group(1)}', name: 'Regex');
      return tabbyMatch.group(1);
    }

    return null;
  }

  @override
  Future<List<BillModel>> fromImportXml(XmlDocument document) async {
    await _fetchBillsTypesNumbers();

    final billsXml = document.findAllElements('Bill');
    final materialXml = document.findAllElements('M');
    final sellersXml = document.findAllElements('Q');
    final accountXml = document.findAllElements('A');
    final customerXml = document.findAllElements('Cu');

    Map<String, String> matNameWithId = {};
    Map<String, String> accountWithId = {};
    Map<String, String> customerWithId = {};

    for (var mat in materialXml) {
      String matGuid = mat.findElements('mptr').first.text;
      String matName = mat.findElements('MatName').first.text;
      matNameWithId[matGuid] = matName.encodeProblematic();
    }
    for (var acc in accountXml) {
      String accId = acc.findElements('AccPtr').first.text;
      String accName = acc.findElements('AccName').first.text;
      accountWithId[accId] = accName;
    }
    // accountWithId['00000000-0000-0000-0000-000000000000']='';
    for (var cu in customerXml) {
      String cuGuid = cu.findElements('cptr').first.text;
      String cuName = cu.findElements('CustName').first.text;
      customerWithId[cuGuid] = cuName;
    }

    Map<String, String> sellerNameID = {};

    for (var sel in sellersXml) {
      String selGuid = sel.findElements('CostGuid').first.text;
      String selName = sel.findElements('CostName').first.text;
      sellerNameID[selGuid] = selName;
    }

    List<BillModel> bills = [];

    log(billsXml.length.toString(), name: 'billsXml');

    for (var billElement in billsXml) {
      String? customerPhone;
      String? orderNumber;

      final noteText = billElement
          .findElements('B')
          .single
          .findElements('Note')
          .single
          .text
          .trim();

      // log('Processing Note: $noteText', name: 'XML Processing');

      // Phone number detection
      if (RegExp(r'^05\d{8}$').hasMatch(noteText)) {
        // log('Detected Phone Number: $noteText', name: 'Phone');
        customerPhone = noteText;
      }

      // Extract order number
      String? extractedOrderNumber = _extractOrderNumber(noteText);
      if (extractedOrderNumber != null) {
        // log('Extracted Order Number: $extractedOrderNumber', name: 'Order Number');
        orderNumber = extractedOrderNumber;
      }

      final itemsElement = billElement.findElements('Items').single;
      final List<Map<String, dynamic>> itemsJson =
          itemsElement.findElements('I').map((iElement) {
        if (read<MaterialController>().getMaterialByName(
                matNameWithId[iElement.findElements('MatPtr').single.text]) ==
            null) {
          log('name ${matNameWithId[iElement.findElements('MatPtr').single.text]}',
              name: 'XML Processing name');
        }
        return {
          'MatPtr': read<MaterialController>()
              .getMaterialByName(
                  matNameWithId[iElement.findElements('MatPtr').single.text])!
              .id,
          // 'MatPtr': iElement.findElements('MatPtr').single.text,

          /// to get the same material name in our database
          'MatName': read<MaterialController>()
              .getMaterialByName(
                  matNameWithId[iElement.findElements('MatPtr').single.text])!
              .matName,
          // 'MatName': matNameWithId[iElement.findElements('MatPtr').single.text],
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
          'LengthWidthHeight':
              iElement.findElements('LengthWidthHeight').single.text,
          'Guid': iElement.findElements('Guid').single.text,
          'VatRatio': iElement.findElements('VatRatio').single.text,
          'SoGuid': iElement.findElements('SoGuid').single.text,
          'SoType': iElement.findElements('SoType').single.text,
        };
      }).toList();

      Map<String, dynamic> billJson = {
        'B': {
          'BillTypeGuid': billElement
              .findElements('B')
              .single
              .findElements('BillTypeGuid')
              .single
              .text,
          'BillGuid': billElement
              .findElements('B')
              .single
              .findElements('BillGuid')
              .single
              .text,
          'BillBranch': billElement
              .findElements('B')
              .single
              .findElements('BillBranch')
              .single
              .text,
          'BillPayType': billElement
              .findElements('B')
              .single
              .findElements('BillPayType')
              .single
              .text,
          'BillCheckTypeGuid': billElement
              .findElements('B')
              .single
              .findElements('BillCheckTypeGuid')
              .single
              .text,
          'BillNumber': _getNextBillNumber(
            billTypeGuid: billElement
                .findElements('B')
                .single
                .findElements('BillTypeGuid')
                .single
                .text,
            items: itemsJson,
          ),
          'BillMatAccGuid': billElement
              .findElements('B')
              .single
              .findElements('BillMatAccGuid')
              .single
              .text,
          'BillCustPtr': read<CustomersController>()
                  .getCustomerById(customerWithId[billElement
                      .findElements('B')
                      .single
                      .findElements('BillCustAcc')
                      .single
                      .text])
                  ?.id ??
              '',
          'BillCustAccId': read<AccountsController>().getAccountIdByName(
              accountWithId[billElement
                  .findElements('B')
                  .single
                  .findElements('BillCustAcc')
                  .single
                  .text]),
          // 'BillCustAccId': billElement.findElements('B').single.findElements('BillCustAcc').single.text,
          'BillCustAccName': accountWithId[billElement
              .findElements('B')
              .single
              .findElements('BillCustAcc')
              .single
              .text],
          'BillCurrencyGuid': billElement
              .findElements('B')
              .single
              .findElements('BillCurrencyGuid')
              .single
              .text,
          'BillCurrencyVal': billElement
              .findElements('B')
              .single
              .findElements('BillCurrencyVal')
              .single
              .text,
          'BillDate': billElement
              .findElements('B')
              .single
              .findElements('BillDate')
              .single
              .text,
          'BillStoreGuid': billElement
              .findElements('B')
              .single
              .findElements('BillStoreGuid')
              .single
              .text,
          'Note': billElement
              .findElements('B')
              .single
              .findElements('Note')
              .single
              .text,
          'CustomerPhone': customerPhone,
          'OrderNumber': orderNumber,
          'BillCostGuid': read<SellersController>().getSellerIdByName(
              sellerNameID[billElement
                  .findElements('B')
                  .single
                  .findElements('BillCostGuid')
                  .single
                  .text]),
          'BillVendorSalesMan': billElement
              .findElements('B')
              .single
              .findElements('BillVendorSalesMan')
              .single
              .text,
          'BillFirstPay': billElement
              .findElements('B')
              .single
              .findElements('BillFirstPay')
              .single
              .text,
          'BillFPayAccGuid': billElement
              .findElements('B')
              .single
              .findElements('BillFPayAccGuid')
              .single
              .text,
          'BillSecurity': billElement
              .findElements('B')
              .single
              .findElements('BillSecurity')
              .single
              .text,
          'BillTransferGuid': billElement
              .findElements('B')
              .single
              .findElements('BillTransferGuid')
              .single
              .text,
          'BillFld1': billElement
              .findElements('B')
              .single
              .findElements('BillFld1')
              .single
              .text,
          'BillFld2': billElement
              .findElements('B')
              .single
              .findElements('BillFld2')
              .single
              .text,
          'BillFld3': billElement
              .findElements('B')
              .single
              .findElements('BillFld3')
              .single
              .text,
          'BillFld4': billElement
              .findElements('B')
              .single
              .findElements('BillFld4')
              .single
              .text,
          'ItemsDiscAcc': billElement
              .findElements('B')
              .single
              .findElements('ItemsDiscAcc')
              .single
              .text,
          'ItemsExtraAccGUID': billElement
              .findElements('B')
              .single
              .findElements('ItemsExtraAccGUID')
              .single
              .text,
          'CostAccGUID': billElement
              .findElements('B')
              .single
              .findElements('CostAccGUID')
              .single
              .text,
          'StockAccGUID': billElement
              .findElements('B')
              .single
              .findElements('StockAccGUID')
              .single
              .text,
          'BonusAccGUID': billElement
              .findElements('B')
              .single
              .findElements('BonusAccGUID')
              .single
              .text,
          'BonusContraAccGUID': billElement
              .findElements('B')
              .single
              .findElements('BonusContraAccGUID')
              .single
              .text,
          'VATAccGUID': billElement
              .findElements('B')
              .single
              .findElements('VATAccGUID')
              .single
              .text,
          'DIscCard': billElement
              .findElements('B')
              .single
              .findElements('DIscCard')
              .single
              .text,
          'BillAddressGUID': billElement
              .findElements('B')
              .single
              .findElements('BillAddressGUID')
              .single
              .text,
        }
      };

      billJson['Items'] = {"I": itemsJson};
      bool freeBill = false;

      final BillModel bill = BillModel.fromImportedJsonFile(billJson, freeBill);

      final List<BillModel> splitBills = _divideLargeBillUseCase.execute(bill);
      bills.addAll(splitBills);
    }
    log(bills.length.toString(), name: 'bills');
    // 🔹 Use the Use Case for linking bills
    final linkedBills = _convertBillsToLinkedListUseCase.execute(bills);

    // return [];
    await _saveBillsTypesNumbers();

    return linkedBills;
  }
}
