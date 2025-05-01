import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/date_format_extension.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/pay_item_model.dart';

class BondImport extends ImportServiceBase<BondModel>
    with FirestoreSequentialNumbers {
  /// Converts the imported JSON structure to a list of BondModel
  @override
  List<BondModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> bondsJson =
        jsonContent['MainExp']['Export']['Pay']['P'] ?? [];
    return bondsJson
        .map((bondJson) =>
            BondModel.fromImportedJsonFile(bondJson as Map<String, dynamic>))
        .toList();
  }

  Map<String, int> bondsNumbers = {
    for (var bondType in BondType.values) bondType.typeGuide: 0
  };

  Future<void> _initializeNumbers() async {
    bondsNumbers = {
      for (var billType in BondType.values)
        billType.typeGuide: await getLastNumber(
          category: ApiConstants.bonds,
          entityType: billType.label,
          // number: 0,
        )
    };
  }

  int getLastBondNumber(String billTypeGuid) {
    if (!bondsNumbers.containsKey(billTypeGuid)) {
      throw Exception('Bond type not found');
    }
    bondsNumbers[billTypeGuid] = bondsNumbers[billTypeGuid]! + 1;
    return bondsNumbers[billTypeGuid]!;
  }

  _setLastNumber() async {
    bondsNumbers.forEach(
      (billTypeGuid, number) async {
        await setLastUsedNumber(ApiConstants.bonds,
            BondType.byTypeGuide(billTypeGuid).label, number);
      },
    );
  }

  bool entryBond = false;

  @override
  Future<List<BondModel>> fromImportXml(XmlDocument document) async {
    await _initializeNumbers();

    final bondNodes = entryBond
        ? document.findAllElements('W')
        : document.findAllElements('P');

    final accountWithName = document.findAllElements('A');

    Map<String, String> accNameWithId = {};

    for (var acc in accountWithName) {
      String accId = acc.findElements('AccPtr').first.text;
      String accName = acc.findElements('AccName').first.text;
      accNameWithId[accId] = accName;
    }

    List<BondModel> bonds = bondNodes.map((node) {
      final payItemsNode = node.getElement('PayItems');

      final payItemList = payItemsNode?.findAllElements('N').map((itemNode) {
            return PayItem(
              entryAccountName:
                  accNameWithId[itemNode.getElement('EntryAccountGuid')?.text],
              // read<AccountsController>().getAccountNameById(itemNode.getElement('EntryAccountGuid')?.text),
              // entryAccountGuid: itemNode.getElement('EntryAccountGuid')?.text,
              entryAccountGuid: read<AccountsController>().getAccountIdByName(
                  accNameWithId[itemNode.getElement('EntryAccountGuid')?.text]),
              entryDate: (itemNode
                  .getElement('EntryDate')!
                  .text
                  .toYearMonthDayFormat()),
              entryDebit: double.tryParse(
                  itemNode.getElement('EntryDebit')?.text ?? '0'),
              entryCredit: double.tryParse(
                  itemNode.getElement('EntryCredit')?.text ?? '0'),
              entryNote: itemNode.getElement('EntryNote')?.text,
              entryCurrencyGuid: itemNode.getElement('EntryCurrencyGuid')?.text,
              entryCurrencyVal: double.tryParse(
                  itemNode.getElement('EntryCurrencyVal')?.text ?? '0'),
              entryCostGuid: itemNode.getElement('EntryCostGuid')?.text,
              entryClass: itemNode.getElement('EntryClass')?.text,
              entryNumber:
                  int.tryParse(itemNode.getElement('EntryNumber')?.text ?? '0'),
              entryCustomerGuid: itemNode.getElement('EntryCustomerGuid')?.text,
              entryType:
                  int.tryParse(itemNode.getElement('EntryType')?.text ?? '0'),
            );
          }).toList() ??
          [];

      // إنشاء كائن BondModel
      return BondModel(
        payTypeGuid: entryBond
            ? '2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de'
            : node.getElement('PayTypeGuid')?.text,
        payNumber: entryBond
            ? getLastBondNumber('2a550cb5-4e91-4e68-bacc-a0e7dcbbf1de')
            : getLastBondNumber(node.getElement('PayTypeGuid')!.text),
        payGuid: entryBond
            ? node.getElement('CEntryGuid')?.text
            : node.getElement('PayGuid')?.text,
        payBranchGuid: entryBond
            ? node.getElement('CEntryBranch')?.text
            : node.getElement('PayBranchGuid')?.text,
        payDate: entryBond
            ? node.getElement('CEntryDate')?.text.toYearMonthDayFormat()
            : node.getElement('PayDate')?.text.toYearMonthDayFormat(),
        entryPostDate: entryBond
            ? node.getElement('CEntryPostDate')?.text
            : node.getElement('EntryPostDate')?.text,
        payNote: entryBond
            ? node.getElement('CEntryNote')?.text
            : node.getElement('PayNote')?.text,
        payCurrencyGuid: entryBond
            ? node.getElement('CEntryCurrencyGuid')?.text
            : node.getElement('PayCurrencyGuid')?.text,
        payCurVal: entryBond
            ? double.tryParse(
                (node.getElement('CEntryDebit')?.text)!.replaceAll(',', ''))
            : double.tryParse(node.getElement('PayCurVal')?.text ?? '0'),
        payAccountGuid: entryBond
            ? '00000000-0000-0000-0000-000000000000'
            : node.getElement('PayAccountGuid')?.text,
        paySecurity: entryBond
            ? int.tryParse(node.getElement('CEntrySecurity')?.text ?? '0')
            : int.tryParse(node.getElement('PaySecurity')?.text ?? '0'),
        paySkip: entryBond
            ? 0
            : int.tryParse(node.getElement('PaySkip')?.text ?? '0'),
        erParentType: entryBond
            ? 0
            : int.tryParse(node.getElement('ErParentType')?.text ?? '0'),
        payItems: PayItems(itemList: payItemList),
        e: node.getElement('E')?.text,
      );
    }).toList();
    await _setLastNumber();
    return bonds;
  }
}