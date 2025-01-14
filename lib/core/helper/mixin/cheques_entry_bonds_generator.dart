import 'package:ba3_bs/features/cheques/data/models/cheques_model.dart';

import '../../../features/bond/data/models/entry_bond_model.dart';
import '../../../features/cheques/service/cheques_bond_service.dart';
import '../enums/enums.dart';

class ChequesEntryBondsGenerator with ChequesBondService {
  List<EntryBondModel> generateEntryBonds(List<ChequesModel> chequesList) => chequesList
      .map(
        (cheques) => createEntryBondModel(
          originType: EntryBondType.cheque,
          chequesModel: cheques
        ),
      )
      .toList();
}
