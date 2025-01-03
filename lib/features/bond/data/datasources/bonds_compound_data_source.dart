import 'package:ba3_bs/core/helper/enums/enums.dart';
import 'package:ba3_bs/core/models/count_query_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';

import '../../../../core/models/date_filter.dart';
import '../../../../core/services/firebase/interfaces/compound_datasource_base.dart';
import '../models/bond_model.dart';

class BondCompoundDataSource extends CompoundDatasourceBase<BondModel, BondType> {
  BondCompoundDataSource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bonds", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.bondsPath; // Collection name in Firestore

  @override
  Future<List<BondModel>> fetchAll({required BondType itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
    );

    final bonds = data.map((item) => BondModel.fromJson(item)).toList();

    bonds.sort((a, b) => a.payNumber!.compareTo(b.payNumber!));

    return bonds;
  }

  @override
  Future<List<BondModel>> fetchWhere<V>(
      {required BondType itemTypeModel, required String field, required V value, DateFilter? dateFilter}) async {
    final data = await compoundDatabaseService.fetchWhere(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: getRootDocumentId(itemTypeModel),
        subCollectionPath: getSubCollectionPath(itemTypeModel),
        field: field,
        value: value,
        dateFilter: dateFilter);

    final users = data.map((item) => BondModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<BondModel> fetchById({required String id, required BondType itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: id,
    );

    return BondModel.fromJson(data);
  }

  @override
  Future<void> delete({required BondModel item}) async {
    BondType bondType = BondType.byTypeGuide(item.payTypeGuid!);
    final rootDocumentId = getRootDocumentId(bondType);
    final subCollectionPath = getSubCollectionPath(bondType);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.payGuid!,
    );
  }

  @override
  Future<BondModel> save({required BondModel item, bool? save}) async {
    BondType bondType = BondType.byTypeGuide(item.payTypeGuid!);

    final rootDocumentId = getRootDocumentId(bondType);
    final subCollectionPath = getSubCollectionPath(bondType);
    if (item.payGuid == null) {
      final newBondModel =
          await _createNewBond(bond: item, rootDocumentId: rootDocumentId, subCollectionPath: subCollectionPath);
      return newBondModel;
    } else {
      await compoundDatabaseService.update(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: rootDocumentId,
        subCollectionPath: subCollectionPath,
        subDocumentId: item.payGuid!,
        data: item.toJson(),
      );
      return item;
    }
  }

  Future<BondModel> _createNewBond(
      {required BondModel bond, required String rootDocumentId, required String subCollectionPath}) async {
    BondType bondType = BondType.byTypeGuide(bond.payTypeGuid!);
    final newBondNumber = await getNextNumber(rootCollectionPath, bondType.label);

    final newBondJson = bond.copyWith(payNumber: newBondNumber, payTypeGuid: bondType).toJson();

    final data = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      data: newBondJson,
    );

    return BondModel.fromJson(data);
  }

  @override
  Future<int> countDocuments({required BondType itemTypeModel, CountQueryFilter<dynamic>? countQueryFilter}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final count = await compoundDatabaseService.countDocuments(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      countQueryFilter: countQueryFilter,
    );

    return count;
  }

  @override
  Future<Map<BondType, List<BondModel>>> fetchAllNested(
      {required String rootCollectionPath, required List<BondType> itemTypes}) {
    // TODO: implement fetchAllNested
    throw UnimplementedError();
  }
}
