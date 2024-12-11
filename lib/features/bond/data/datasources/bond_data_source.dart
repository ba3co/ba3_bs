import 'package:ba3_bs/features/bond/data/models/bond_record_model.dart';

import '../../../../core/services/firebase/implementations/firebase_sequential_number_database.dart';
import '../../../../core/services/firebase/interfaces/database_with_result_base.dart';

class BondsDataSource extends DatabaseWithResultBase<BondModel> with FirebaseSequentialNumberDatabase {
  BondsDataSource({required super.databaseService});

  @override
  String get path => 'bonds';

  @override
  Future<List<BondModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);

    final List<BondModel> bonds = data.map((item) => BondModel.fromJson(item)).toList();

    // Sort the list by `bondNumber` in ascending order
    bonds.sort((a, b) => a.bondCode!.compareTo(b.bondCode!));

    return bonds;
  }

  @override
  Future<BondModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return BondModel.fromJson(item);
  }

  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }

  @override
  Future<BondModel> save(BondModel item) async {
    if (item.bondId == null) {
      final newBillModel = await _createNewBond(item);

      return newBillModel;
    } else {
      await databaseService.update(path: path, documentId: item.bondId!, data: item.toJson());
      return item;
    }
  }

  Future<BondModel> _createNewBond(BondModel bond) async {
    final newBondNumber = await getNextNumber(path, bond.bondType!.label);

    final newBondJson = bond.copyWith(bondNumber: newBondNumber).toJson();

    final data = await databaseService.add(path: path, data: newBondJson);

    return BondModel.fromJson(data);
  }
}
