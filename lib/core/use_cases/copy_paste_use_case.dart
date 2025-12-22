import '../../features/bill/data/models/bill_model.dart';
import '../../features/customer/data/models/customer_model.dart';
import '../../features/materials/data/models/materials/material_model.dart';
import '../services/copy_paste_services/copy_paste_json_service.dart';

class CopyPasteJsonUseCase {
  final ClipboardJsonService clipboardService;

  CopyPasteJsonUseCase(this.clipboardService);

  Future<void> copy<T>(dynamic modelOrList) {
    return clipboardService.copy(modelOrList);
  }

  Future<dynamic> paste<T>() async {
    final wrapped = await clipboardService.paste();
    if (wrapped == null) return null;

    final type = wrapped['type'];
    final data = wrapped['data'];

    switch (type) {
      case 'MaterialModel':
        if (data is List) {
          return data.map((e) => MaterialModel.fromJson(e)).toList();
        } else {
          return MaterialModel.fromJson(data);
        }

      case 'CustomerModel':
        if (data is List) {
          return data.map((e) => CustomerModel.fromJson(e)).toList();
        } else {
          return CustomerModel.fromJson(data);
        }

      case 'BillModel':
        if (data is List) {
          return data.map((e) => BillModel.fromJson(e)).toList();
        } else {
          return BillModel.fromJson(data);
        }

    // and so on for anything with fromJson()

      default:
        throw Exception("Unsupported pasted type: $type");
    }
  }
}
