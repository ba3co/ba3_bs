import 'package:ba3_bs/features/accounts/data/models/account_model.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class AccountImport extends ImportServiceBase<AccountModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<AccountModel> fromImportJson(Map<String, dynamic> jsonContent) {
    return [];
  }

  @override
  List<AccountModel> fromImportXml(XmlDocument document) {
    final accountNodes = document.findAllElements('A');
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    return accountNodes.map((node) {
      return AccountModel(
        id: node.getElement('AccPtr')?.text,
        accName: node.getElement('AccName')?.text,
        accLatinName: node.getElement('AccLatinName')?.text,
        accCode: node.getElement('AccCode')?.text,
        accCDate: dateFormat.tryParse(node.getElement('AccCDate')?.text ?? ''),
        accCheckDate: dateFormat.tryParse(node.getElement('AccCheckDate')?.text ?? ''),
        accParentGuid: node.getElement('AccParentGuid')?.text,
        accFinalGuid: node.getElement('AccFinalGuid')?.text,
        accAccNSons: int.tryParse(node.getElement('AccAccNSons')?.text ?? '0'),
        accInitDebit: double.tryParse(node.getElement('AccInitDebit')?.text ?? '0'),
        accInitCredit: double.tryParse(node.getElement('AccInitCredit')?.text ?? '0'),
        maxDebit: double.tryParse(node.getElement('MaxDebit')?.text ?? '0'),
        accWarn: int.tryParse(node.getElement('AccWarn')?.text.toString() ?? '0'),
        note: node.getElement('Note')?.text,
        accCurVal: int.tryParse(node.getElement('AccCurVal')?.text ?? '0'),
        accCurGuid: node.getElement('AccCurGuid')?.text,
        accSecurity: int.tryParse(node.getElement('AccSecurity')?.text ?? '0'),
        accDebitOrCredit: int.tryParse(node.getElement('AccDebitOrCredit')?.text ?? '0'),
        accType: int.tryParse(node.getElement('AccType')?.text ?? '0'),
        accState: int.tryParse(node.getElement('AccState')?.text ?? '0'),
        accIsChangableRatio: int.tryParse(node.getElement('AccIsChangableRatio')?.text ?? '0'),
        accBranchGuid: node.getElement('AccBranchGuid')?.text,
        accNumber: int.tryParse(node.getElement('AccNumber')?.text ?? '0'),
        accBranchMask: int.tryParse(node.getElement('AccBranchMask')?.text ?? '0'),
      );
    }).toList();
  }

}
