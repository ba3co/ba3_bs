import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/services/firebase/interfaces/remote_datasource_base.dart';
import '../models/bond_type.dart';

class BondTypeDataSource extends RemoteDatasourceBase<BondTypeModel> {
  BondTypeDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.bondTypes; // Collection name in Firestore

  @override
  Future<List<BondTypeModel>> fetchAll() async {

    final data = await databaseService.fetchAll(path: path);

    debugPrint("Future<List<BondTypeModel>> fetchAll() called data : $data");

    final List<BondTypeModel> bondTypes =
    data.map((item) => BondTypeModel.fromJson(item)).toList();

    //bondTypes.sort((a, b) => a.from.compareTo(b.from));

    debugPrint(bondTypes.toString());

    return bondTypes;
  }

  @override
  Future<BondTypeModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return BondTypeModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<BondTypeModel> save(BondTypeModel item) async {
    final data = {
      'label': item.label,
      'value': item.value,
      'from': item.from,
      'to': item.to,
      'taxType': item.taxType,
      'color': item.color,
      'type':item.type.name,
      'typeGuide':item.typeGuide
    };

    await databaseService.add(path: path,  data: data);

    return item;
  }
}
