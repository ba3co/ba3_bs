// MaterialsDataSource Implementation
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/bulk_savable_datasource.dart';

import '../../models/material_model.dart';

class MaterialsDataSource extends BulkSavableDatasource<MaterialModel> {
  MaterialsDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.materials; // Collection name in Firestore

  @override
  Future<List<MaterialModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final sellers = data.map((item) => MaterialModel.fromJson(item)).toList();

    return sellers;
  }

  @override
  Future<MaterialModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return MaterialModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<MaterialModel> save(MaterialModel item) async {
    final data = await databaseService.add(path: path, documentId: item.id, data: item.toJson());

    return MaterialModel.fromJson(data);
  }

  @override
  Future<List<MaterialModel>> saveAll(List<MaterialModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => {...item.toJson(), 'docId': item.id}).toList(),
    );

    return savedData.map(MaterialModel.fromJson).toList();
  }
}
