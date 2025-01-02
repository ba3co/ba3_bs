import 'package:ba3_bs/features/bond/data/models/bond_model.dart';

import '../../../../core/services/json_file_operations/interfaces/import/json_import_service_base.dart';

class BondJsonImport extends JsonImportServiceBase<BondModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BondModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['MainExp']['Export']['Pay']['P'] ?? [];
    List<BondModel> sss= billsJson.map((bondJson) => BondModel.fromImportedJsonFile(bondJson as Map<String, dynamic>)).toList();
    return sss;
  }


}
