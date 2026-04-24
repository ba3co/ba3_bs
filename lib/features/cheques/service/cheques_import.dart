import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/helper/extensions/basic/date_format_extension.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import 'package:ba3_bs/features/accounts/controllers/accounts_controller.dart';
import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';
import 'package:xml/xml.dart';

import '../../../../core/services/json_file_operations/interfaces/import/import_service_base.dart';

class ChequesImport extends ImportServiceBase<ChequesModel>
    with FirestoreSequentialNumbers {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<ChequesModel> fromImportJson(Map<String, dynamic> jsonContent) {
    return [];
  }

  late Map<String, int> _chequesNumbersByTypeGuid;

  Future<void> _initializeNumbers() async {
    _chequesNumbersByTypeGuid = {
      for (final t in ChequesType.values)
        t.typeGuide: await getLastNumber(
          category: ApiConstants.cheques,
          entityType: t.typeGuide,
        )
    };
  }

  int _getNextChequeNumber(String typeGuid) {
    if (!_chequesNumbersByTypeGuid.containsKey(typeGuid)) {
      throw Exception('Cheque type not found for guid: $typeGuid');
    }
    _chequesNumbersByTypeGuid[typeGuid] =
        _chequesNumbersByTypeGuid[typeGuid]! + 1;
    return _chequesNumbersByTypeGuid[typeGuid]!;
  }

  Future<void> _persistChequeSequenceNumbers() async {
    for (final entry in _chequesNumbersByTypeGuid.entries) {
      await setLastUsedNumber(
        ApiConstants.cheques,
        entry.key,
        entry.value,
      );
    }
  }

  @override
  Future<List<ChequesModel>> fromImportXml(XmlDocument document) async {
    await _initializeNumbers();

    final chequesElements = document.findAllElements('H');
    final result = chequesElements.map((element) {
      final typeGuid = element.findElements('CheckTypeGuid').first.text;
      final checkCollectEntries = element.findElements('CheckCollectEntry');
      String? chequesPayGuid;
      String? chequesPayDate;
      if (checkCollectEntries.isNotEmpty) {
        for (var el in checkCollectEntries) {
          chequesPayGuid =
              el.firstElementChild!.findElements('CEntryGuid').first.text;
          chequesPayDate =
              el.firstElementChild!.findElements('CEntryDate').first.text;
        }
      }

      return ChequesModel(
        chequesTypeGuid: typeGuid,
        chequesNumber: _getNextChequeNumber(typeGuid),
        chequesNum: int.tryParse(element.findElements('CheckNum').first.text),
        chequesGuid: element.findElements('CheckGuid').first.text,
        chequesDate:
            element.findElements('CheckDate').first.text.toYearMonthDayFormat(),
        chequesDueDate: element
            .findElements('CheckDueDate')
            .first
            .text
            .toYearMonthDayFormat(),
        chequesNote: element.findElements('CheckNote').first.text,
        chequesVal:
            double.tryParse(element.findElements('CheckVal').first.text),
        chequesAccount2Guid:
            element.findElements('CheckAccount2Guid').first.text,
        accPtr: element.findElements('AccPtr').first.text,
        isPayed: checkCollectEntries.isNotEmpty,
        chequesPayGuid: checkCollectEntries.isNotEmpty ? chequesPayGuid : null,
        chequesPayDate: checkCollectEntries.isNotEmpty
            ? chequesPayDate!.toYearMonthDayFormat()
            : null,
        accPtrName: read<AccountsController>()
            .getAccountNameById(element.findElements('AccPtr').first.text),
        chequesAccount2Name: read<AccountsController>().getAccountNameById(
            element.findElements('CheckAccount2Guid').first.text),
      );
    }).toList();

    await _persistChequeSequenceNumbers();
    return result;
  }
}
