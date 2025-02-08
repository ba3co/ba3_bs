import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/materials/controllers/material_controller.dart';
import 'package:ba3_bs/features/sellers/controllers/sellers_controller.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/bill_items.dart';
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
        )
    };
  }

  List<List<dynamic>> _itemsChunks(List<Map<String, dynamic>> items, int maxItemsPerBill) => items.chunkBy((maxItemsPerBill));

  /// Splits a large bill into multiple smaller bills, each having at most `maxItemsPerBill` items.
  List<BillModel> _splitBillIntoSmallerBills(BillModel bill, {required int maxItemsPerBill}) {
    final List<BillModel> splitBills = [];
    final items = bill.items.itemList;
    final chunks = items.chunkBy((maxItemsPerBill));

    for (int i = 0; i < chunks.length; i++) {
      final newBill = bill.copyWith(
        billId: "${bill.billId}_part${i + 1}", // Assign new unique ID
        billDetails: bill.billDetails.copyWith(
          billNumber: bill.billDetails.billNumber! + i,
        ),
        items: BillItems(itemList: chunks[i]),
      );
      splitBills.add(newBill);
    }

    return splitBills;
  }

  int getLastBillNumber({required String billTypeGuid, required List<Map<String, dynamic>> items}) {
    if (!billsNumbers.containsKey(billTypeGuid)) {
      throw Exception('Bill type not found');
    }

    final chunks = _itemsChunks(items, AppConstants.maxItemsPerBill);

    if (chunks.length > 1) {
      final lastBillNumber = billsNumbers[billTypeGuid];
      billsNumbers[billTypeGuid] = lastBillNumber! + chunks.length;
      return lastBillNumber + 1;
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
    final sellersXml = document.findAllElements('Q');

    Map<String, String> matNameWithId = {};

    for (var mat in materialXml) {
      String matGuid = mat.findElements('mp tr').first.text;
      String amtName = mat.findElements('MatName').first.text;
      matNameWithId[matGuid] = amtName;
    }

    Map<String, String> sellerNameID = {};

    for (var sel in sellersXml) {
      String selGuid = sel.findElements('CostGuid').first.text;
      String selName = sel.findElements('CostName').first.text;
      sellerNameID[selGuid] = selName;
    }

    List<BillModel> bills = [];

    for (var billElement in billsXml) {
      final itemsElement = billElement.findElements('Items').single;
      final List<Map<String, dynamic>> itemsJson = itemsElement.findElements('I').map((iElement) {
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

      Map<String, dynamic> billJson = {
        'B': {
          'BillTypeGuid': billElement.findElements('B').single.findElements('BillTypeGuid').single.text,
          'BillGuid': billElement.findElements('B').single.findElements('BillGuid').single.text,
          'BillBranch': billElement.findElements('B').single.findElements('BillBranch').single.text,
          'BillPayType': billElement.findElements('B').single.findElements('BillPayType').single.text,
          'BillCheckTypeGuid': billElement.findElements('B').single.findElements('BillCheckTypeGuid').single.text,
          'BillNumber': getLastBillNumber(
            billTypeGuid: billElement.findElements('B').single.findElements('BillTypeGuid').single.text,
            items: itemsJson,
          ),
          'BillCustPtr': billElement.findElements('B').single.findElements('BillCustAcc').single.text,
          'BillCustName': read<AccountsController>().getAccountNameById(billElement.findElements('B').single.findElements('BillCustAcc').single.text),
          'BillCurrencyGuid': billElement.findElements('B').single.findElements('BillCurrencyGuid').single.text,
          'BillCurrencyVal': billElement.findElements('B').single.findElements('BillCurrencyVal').single.text,
          'BillDate': billElement.findElements('B').single.findElements('BillDate').single.text,
          'BillStoreGuid': billElement.findElements('B').single.findElements('BillStoreGuid').single.text,
          'Note': billElement.findElements('B').single.findElements('Note').single.text,
          'BillMatAccGuid': billElement.findElements('B').single.findElements('BillMatAccGuid').single.text,
          'BillCostGuid': read<SellersController>()
              .getSellerIdByName(sellerNameID[billElement.findElements('B').single.findElements('BillCostGuid').single.text]),
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

      billJson['Items'] = {"I": itemsJson};

      final BillModel bill = BillModel.fromImportedJsonFile(billJson);

      final chunks = _itemsChunks(itemsJson, AppConstants.maxItemsPerBill);

      if (chunks.length > 1) {
        final List<BillModel> splitBills = _splitBillIntoSmallerBills(bill, maxItemsPerBill: AppConstants.maxItemsPerBill);
        bills.addAll(splitBills);
      } else {
        bills.add(bill);
      }
    }

    await setLastNumber();
    return bills;
  }
}
