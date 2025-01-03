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
    return accountNodes.where((account) => account.getElement('AccName')?.text!='',).map((account) {
      return AccountModel(
        id: account.getElement('AccPtr')?.text,
        accName: account.getElement('AccName')?.text,
        accLatinName: account.getElement('AccLatinName')?.text,
        accCode: account.getElement('AccCode')?.text,
        accCDate: dateFormat.tryParse(account.getElement('AccCDate')?.text ?? ''),
        accCheckDate: dateFormat.tryParse(account.getElement('AccCheckDate')?.text ?? ''),
        accParentGuid: account.getElement('AccParentGuid')?.text,
        accFinalGuid: account.getElement('AccFinalGuid')?.text,
        accAccNSons: int.parse(account.getElement('AccAccNSons')?.text ?? '0'),
        accInitDebit: double.parse(account.getElement('AccInitDebit')?.text ?? '0'),
        accInitCredit: double.parse(account.getElement('AccInitCredit')?.text ?? '0'),
        maxDebit: double.parse(account.getElement('MaxDebit')?.text ?? '0'),
        accWarn: double.parse(account.getElement('AccWarn')?.text.toString() ?? '0').toInt(),
        note: account.getElement('Note')?.text,
        accCurVal: int.parse(account.getElement('AccCurVal')?.text ?? '0'),
        accCurGuid: account.getElement('AccCurGuid')?.text,
        accSecurity: int.parse(account.getElement('AccSecurity')?.text ?? '0'),
        accDebitOrCredit: int.parse(account.getElement('AccDebitOrCredit')?.text ?? '0'),
        accType: int.parse(account.getElement('AccType')?.text ?? '0'),
        accState: int.parse(account.getElement('AccState')?.text ?? '0'),
        accIsChangableRatio: int.parse(account.getElement('AccIsChangableRatio')?.text ?? '0'),
        accBranchGuid: account.getElement('AccBranchGuid')?.text,
        accNumber: int.parse(account.getElement('AccNumber')?.text ?? '0'),
        accBranchMask: int.parse(account.getElement('AccBranchMask')?.text ?? '0'),
      );
    }).toList();
  }

}
