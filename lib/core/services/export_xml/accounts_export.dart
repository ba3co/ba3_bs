import 'package:ba3_bs/core/services/export_xml/xml_helpers.dart';
import 'package:xml/xml.dart' as xml;

import '../../../features/accounts/data/models/account_model.dart';

class AccountsExport {
    xml.XmlElement exportAccounts(List<AccountModel> accounts) {
    final accountElements = <xml.XmlNode>[
      xml.XmlElement(xml.XmlName('AccountsCount'), [], [xml.XmlText(accounts.length.toStringAsFixed(2))]),
      ...accounts.map((acc) => _buildAccountElement(acc)),
    ];

    return xml.XmlElement(xml.XmlName('Accounts'), [], accountElements);
  }

    xml.XmlElement _buildAccountElement(AccountModel acc) {
    return xml.XmlElement(
      xml.XmlName('A'),
      [],
      [
        XmlHelpers.element('AccPtr', acc.id),
        XmlHelpers.element('AccName', acc.accName),
        XmlHelpers.element('AccLatinName', acc.accLatinName),
        XmlHelpers.element('AccCode', acc.accCode),
        XmlHelpers.element('AccCDate', acc.accCDate?.toIso8601String().split('T').first),
        XmlHelpers.element('AccCheckDate', acc.accCheckDate?.toIso8601String().split('T').first),
        XmlHelpers.element('AccParentGuid', acc.accParentGuid),
        XmlHelpers.element('AccFinalGuid', acc.accFinalGuid),
        XmlHelpers.element('AccAccNSons', acc.accAccNSons?.toString()),
        XmlHelpers.element('AccInitDebit', acc.accInitDebit?.toString() ?? '0.00'),
        XmlHelpers.element('AccInitCredit', acc.accInitCredit?.toString() ?? '0.00'),
        XmlHelpers.element('MaxDebit', acc.maxDebit?.toString() ?? '0.00'),
        XmlHelpers.element('AccWarn', acc.accWarn?.toString() ?? '0.00'),
        XmlHelpers.element('Note', acc.note),
        XmlHelpers.element('AccCurVal', acc.accCurVal?.toString() ?? '1'),
        XmlHelpers.element('AccCurGuid', acc.accCurGuid),
        XmlHelpers.element('AccSecurity', acc.accSecurity?.toString() ?? '1'),
        XmlHelpers.element('AccDebitOrCredit', acc.accDebitOrCredit?.toString() ?? '0'),
        XmlHelpers.element('AccType', acc.accType?.toString() ?? '1'),
        XmlHelpers.element('AccState', acc.accState?.toString() ?? '0'),
        XmlHelpers.element('AccIsChangableRatio', acc.accIsChangableRatio?.toString() ?? '0'),
        XmlHelpers.element('AccBranchGuid', acc.accBranchGuid ?? '00000000-0000-0000-0000-000000000000'),
        XmlHelpers.element('AccNumber', acc.accNumber?.toString()),
        XmlHelpers.element('AccBranchMask', acc.accBranchMask?.toString() ?? '0'),
      ],
    );
  }


}