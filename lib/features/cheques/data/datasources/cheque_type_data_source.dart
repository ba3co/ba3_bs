import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:flutter/cupertino.dart';
import '../../../../core/services/firebase/interfaces/remote_datasource_base.dart';
import '../models/cheque_type.dart';

class ChequeTypeDataSource extends RemoteDatasourceBase<ChequeType> {
  ChequeTypeDataSource({required super.databaseService});

  @override
  String get path => ApiConstants.chequeTypes; // Firestore collection name

  @override
  Future<List<ChequeType>> fetchAll() async {
    debugPrint("Future<List<ChequeType>> fetchAll() called");
    final data = await databaseService.fetchAll(path: path);

    debugPrint("Data fetched: $data");

    final List<ChequeType> cheques =
    data.map((item) => ChequeType.fromMap(item)).toList();

    // Sort by 'from' value ascending
    cheques.sort((a, b) => a.from.compareTo(b.from));

    debugPrint(cheques.toString());

    return cheques;
  }

  @override
  Future<ChequeType> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return ChequeType.fromMap(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<ChequeType> save(ChequeType item) async {
    final data = item.toMap();

    await databaseService.add(path: path, data: data);

    return item;
  }
}
