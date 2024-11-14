import '../../../../core/services/json_file_operations/abstract/import/base_json_import_service.dart';
import '../../data/models/bill_model.dart';

class BillJsonImport extends BaseJsonImportService<BillModel> {
  /// Converts the imported JSON structure to a list of BillModel
  @override
  List<BillModel> fromImportJson(Map<String, dynamic> jsonContent) {
    final List<dynamic> billsJson = jsonContent['Bill'] ?? [];
    return billsJson.map((billJson) => BillModel.fromImportedJsonFile(billJson as Map<String, dynamic>)).toList();
  }
}
