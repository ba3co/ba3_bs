import 'package:ba3_bs/core/services/local_database/interfaces/local_datasource_base.dart';
import '../../models/materials/material_model.dart';

class MaterialsLocalDatasource extends LocalDatasourceBase<MaterialModel> {
  MaterialsLocalDatasource(super.database);

  @override
  Future<void> saveData(MaterialModel data) {
    // if (data.id == null) {
    //   throw Exception("Material ID cannot be null for saving data.");
    // }
    return database.insert(data.id!, data);
  }

  @override
  Future<void> saveAllData(List<MaterialModel> data) {
    final Map<String, MaterialModel> dataMap = {
      for (var item in data) if (item.id != null) item.id!: item
    };
    return database.insertAll(dataMap);
  }

  @override
  Future<List<MaterialModel>> getAllData() => database.fetchAll();

  @override
  Future<MaterialModel?> getDataById(String id) => database.fetchById(id);

  @override
  Future<void> removeData(MaterialModel item) {
/*    if (item.id == null) {
      throw Exception("Material ID cannot be null for deletion.");
    }*/
    return database.delete(item.id!);
  }

  @override
  Future<void> removeAllData(List<MaterialModel> data) {
    final List<String> ids = [
      for (var item in data) if (item.id != null) item.id!
    ];
    return database.deleteAll(ids);
  }

  @override
  Future<void> clearAllData() => database.clear();

  @override
  Future<void> updateData(MaterialModel data) {
    if (data.id == null) {
      throw Exception("Material ID cannot be null for updating data.");
    }
    return database.update(data.id!, data);
  }

  @override
  Future<void> updateAllData(List<MaterialModel> data) {
    final Map<String, MaterialModel> dataMap = {
      for (var item in data) if (item.id != null) item.id!: item
    };
    return database.updateAll(dataMap);
  }
}
