import 'package:ba3_bs/core/services/firebase/interfaces/datasource_base.dart';

import '../models/bill_type_model.dart';

class PatternsDataSource extends DatasourceBase<BillTypeModel> {
  PatternsDataSource({required super.databaseService});

  @override
  String get path => 'bill_types'; // Collection name in Firestore

  @override
  Future<List<BillTypeModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    final billTypes = data.map((item) => BillTypeModel.fromJson(item)).toList();
    return billTypes;
  }

  @override
  Future<BillTypeModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return BillTypeModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<BillTypeModel> save(BillTypeModel item) async {
    if (item.billTypeId == null) {
      final data = await databaseService.add(path: path, data: item.toJson());

      return BillTypeModel.fromJson(data);
    } else {
      await databaseService.update(path: path, documentId: item.billTypeId, data: item.toJson());
      return item;
    }
  }
}
