import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class ChequesImport extends ImportServiceBase<ChequesModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<ChequesModel> fromImportJson(Map<String, dynamic> jsonContent) {
    return [];
  }

  @override
  List<ChequesModel> fromImportXml(XmlDocument document) {
    final chequesElements = document.findAllElements('H');
    return chequesElements.map((element) {
      return ChequesModel(
        chequesTypeGuid: element.findElements('CheckTypeGuid').first.text,
        chequesNumber: int.tryParse(element.findElements('CheckNumber').first.text),
        chequesNum: int.tryParse(element.findElements('CheckNum').first.text),
        chequesGuid: element.findElements('CheckGuid').first.text,

        chequesDate: element.findElements('CheckDate').first.text,
        chequesDueDate: element.findElements('CheckDueDate').first.text,
        chequesNote: element.findElements('CheckNote').first.text,
        chequesVal: double.tryParse(element.findElements('CheckVal').first.text),
        chequesAccount2Guid: element.findElements('CheckAccount2Guid').first.text,
        accPtr: element.findElements('AccPtr').first.text,
        isPayed:false,
        accPtrName: read<AccountsController>().getAccountNameById(element.findElements('AccPtr').first.text),
        chequesAccount2Name: read<AccountsController>().getAccountNameById(element.findElements('CheckAccount2Guid').first.text),
      );
    }).toList();
  }
}
