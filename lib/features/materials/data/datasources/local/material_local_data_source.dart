import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/core/services/local_database/interfaces/local_datasource_base.dart';
import '../../models/materials/material_model.dart';

class MaterialsLocalDatasource extends LocalDatasourceBase<MaterialModel> {
  MaterialsLocalDatasource(super.database);

  @override
  Future<void> saveData(MaterialModel data) {
    return database.insert(data.id!, data);
  }

  @override
  Future<void> saveAllData(List<MaterialModel> data) {
    final Map<String, MaterialModel> dataMap = data.toMap(
      (material) => material.id!,
    );
    return database.insertAll(dataMap);
  }

  @override
  Future<List<MaterialModel>> getAllData() => database.fetchAll();

  @override
  Future<MaterialModel?> getDataById(String id) => database.fetchById(id);

  @override
  Future<void> removeData(MaterialModel item) {
    return database.delete(item.id!);
  }

  @override
  Future<void> removeAllData(List<MaterialModel> data) {
    final List<String> ids = data.extract(
      (item) => item.id!,
    );
    return database.deleteAll(ids);
  }

  @override
  Future<void> clearAllData() => database.clear();

  @override
  Future<void> updateData(MaterialModel data) {
    return database.update(data.id!, data);
  }

  @override
  Future<void> updateAllData(List<MaterialModel> data) {
    final dataMap = data.toMap(
      (material) => material.id!,
    );

    return database.updateAll(dataMap);
  }
}
