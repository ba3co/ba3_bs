import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/features/tax/data/models/tax_model.dart';

import '../../../../core/services/firebase/implementations/services/firebase_sequential_number_database.dart';
import '../../../../core/services/firebase/interfaces/datasource_base.dart';

class TaxDataSource extends DatasourceBase<TaxModel> with FirebaseSequentialNumberDatabase {
  TaxDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.taxPath; // Collection name in Firestore

  @override
  Future<List<TaxModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final List<TaxModel> taxList = data.map((item) => TaxModel.fromJson(item)).toList();

    // Sort the list by `taxNumber` in ascending order
    taxList.sort((a, b) => a.taxGuid!.compareTo(b.taxGuid!));

    return taxList;
  }

  @override
  Future<TaxModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return TaxModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<TaxModel> save(TaxModel item) async {
    final data = await databaseService.add(path: path, documentId: item.taxGuid, data: item.toJson());
    return TaxModel.fromJson(data);
  }
}
