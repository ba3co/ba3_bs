// EntryBondsDataSource Implementation
import 'dart:developer';

import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/bulk_savable_datasource.dart';
import 'package:ba3_bs/features/bond/data/models/entry_bond_model.dart';

import '../../../../../core/constants/app_config.dart';

class EntryBondsDatasource extends BulkSavableDatasource<EntryBondModel> {
  EntryBondsDatasource({required super.databaseService});

  @override
  String get path => '${AppConfig.instance.year}${ApiConstants.entryBonds}'; // Collection name in Firestore

  @override
  Future<List<EntryBondModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final entryBonds = data.map((item) => EntryBondModel.fromJson(item)).toList();

    return entryBonds;
  }

  @override
  Future<EntryBondModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return EntryBondModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<EntryBondModel> save(EntryBondModel item) async {
    log('save', name: 'EntryBondsDatasource');
    final data = await databaseService.add(
      path: path,
      documentId: item.origin?.docId ?? item.origin?.originId,
      data: item.toJson(),
    );

    return EntryBondModel.fromJson(data);
  }

  @override
  Future<List<EntryBondModel>> saveAll(List<EntryBondModel> items) async {
    final savedData = await databaseService.addAll(
      path: path,
      data: items.map((item) => {...item.toJson(), 'docId': item.origin?.docId ?? item.origin?.originId}).toList(),
    );

    return savedData.map(EntryBondModel.fromJson).toList();
  }
}
