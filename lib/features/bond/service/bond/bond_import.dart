import 'package:ba3_bs/core/helper/extensions/basic/date_format_extension.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/bond/data/models/bond_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';
import '../../data/models/pay_item_model.dart';

class BondImport extends ImportServiceBase<BondModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BondModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Pay']['P'] ?? [];
    return  billsJson.map((bondJson) => BondModel.fromImportedJsonFile(bondJson as Map<String, dynamic>)).toList();
  }

  @override
  List<BondModel> fromImportXml(XmlDocument document) {
    // العثور على جميع العقد <P> داخل <Pay>
    final bondNodes = document.findAllElements('P');

    return bondNodes.map((node) {
      // تحليل العناصر الرئيسية لـ BondModel
      final payItemsNode = node.getElement('PayItems');

      // إنشاء قائمة من PayItem
      final payItemList = payItemsNode?.findAllElements('N').map((itemNode) {
        return PayItem(
          entryAccountName: read<AccountsController>().getAccountNameById(itemNode.getElement('EntryAccountGuid')?.text),
          entryAccountGuid: itemNode.getElement('EntryAccountGuid')?.text,
          entryDate:  (itemNode.getElement('EntryDate')!.text.toYearMonthDayFormat()),
          entryDebit: double.tryParse(itemNode.getElement('EntryDebit')?.text ?? '0'),
          entryCredit: double.tryParse(itemNode.getElement('EntryCredit')?.text ?? '0'),
          entryNote: itemNode.getElement('EntryNote')?.text,
          entryCurrencyGuid: itemNode.getElement('EntryCurrencyGuid')?.text,
          entryCurrencyVal: double.tryParse(itemNode.getElement('EntryCurrencyVal')?.text ?? '0'),
          entryCostGuid: itemNode.getElement('EntryCostGuid')?.text,
          entryClass: itemNode.getElement('EntryClass')?.text,
          entryNumber: int.tryParse(itemNode.getElement('EntryNumber')?.text ?? '0'),
          entryCustomerGuid: itemNode.getElement('EntryCustomerGuid')?.text,
          entryType: int.tryParse(itemNode.getElement('EntryType')?.text ?? '0'),
        );
      }).toList() ?? [];

      // إنشاء كائن BondModel
      return BondModel(
        payTypeGuid: node.getElement('PayTypeGuid')?.text,
        payNumber: int.tryParse(node.getElement('PayNumber')?.text ?? '0'),
        payGuid: node.getElement('PayGuid')?.text,
        payBranchGuid: node.getElement('PayBranchGuid')?.text,
        payDate: node.getElement('PayDate')?.text.toYearMonthDayFormat(),
        entryPostDate: node.getElement('EntryPostDate')?.text,
        payNote: node.getElement('PayNote')?.text,
        payCurrencyGuid: node.getElement('PayCurrencyGuid')?.text,
        payCurVal: double.tryParse(node.getElement('PayCurVal')?.text ?? '0'),
        payAccountGuid: node.getElement('PayAccountGuid')?.text,
        paySecurity: int.tryParse(node.getElement('PaySecurity')?.text ?? '0'),
        paySkip: int.tryParse(node.getElement('PaySkip')?.text ?? '0'),
        erParentType: int.tryParse(node.getElement('ErParentType')?.text ?? '0'),
        payItems: PayItems(itemList: payItemList),
        e: node.getElement('E')?.text,
      );
    }).toList();
  }



}
