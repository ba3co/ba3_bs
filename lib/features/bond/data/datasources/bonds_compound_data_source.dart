import 'package:ba3_bs/core/models/query_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import '../../service/bond/get_bond_types_models_service.dart';
import '../../../../core/models/date_filter.dart';
import '../../../../core/services/firebase/interfaces/compound_datasource_base.dart';
import '../models/bond_type_model.dart';
import '../models/bond_type.dart';
import 'package:get/get.dart';

class BondCompoundDatasource
    extends CompoundDatasourceBase<BondModel, BondTypeModel> {
  BondCompoundDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bonds", "bonds")

  @override
  // String get rootCollectionPath => '${read<MigrationController>().currentVersion}${ApiConstants.bonds}'; // Collection name in Firestore

  String get rootCollectionPath =>
      ApiConstants.bonds; // Collection name in Firestore

  @override

  Future<List<BondModel>> fetchAll({required BondTypeModel itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subCollectionPath = getSubCollectionPath(itemIdentifier);

    /// Fetch all the bonds from the Firestore database.
    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
    );

    /// Convert the data to a list of [BondModel] objects.
    final bonds = data.map((item) => BondModel.fromJson(item)).toList();

    /// Sort the bonds by their pay number in ascending order.
    bonds.sort((a, b) => a.payNumber!.compareTo(b.payNumber!));

    return bonds;
  }
/*   6b23f2ce-af65-43cd-9ec4-dc87faaef5ed   */

  @override
  Future<List<BondModel>> fetchWhere<V>(
      {required BondTypeModel itemIdentifier,
      String? field,
      V? value,
      DateFilter? dateFilter}) async {
    final data = await compoundDatabaseService.fetchWhere(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: getRootDocumentId(itemIdentifier),
        subCollectionPath: getSubCollectionPath(itemIdentifier),
        field: field,
        value: value,
        dateFilter: dateFilter);

    final users = data.map((item) => BondModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<BondModel> fetchById(
      {required String id, required BondTypeModel itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subCollectionPath = getSubCollectionPath(itemIdentifier);

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


    final bondType = Get.find<BondTypeService>().getBondTypeByGuide(item.payTypeGuid!);

    //BondType bondType = BondType.byTypeGuide(item.payTypeGuid!);
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
  Future<BondModel> save({required BondModel item}) async {

    late final String rootDocumentId;
    late final String subCollectionPath;

    if (item.bondTypeLabel != null && item.bondTypeLabel!.isNotEmpty) {
      rootDocumentId = item.payTypeGuid!;
      subCollectionPath = item.bondTypeLabel!;
    } else {
      final bondType = Get.find<BondTypeService>().getBondTypeByGuide(item.payTypeGuid!);
      rootDocumentId = getRootDocumentId(bondType);
      subCollectionPath = getSubCollectionPath(bondType);
    }


    final updatedBond =
        item.payGuid == null ? await _assignBondNumber(item) : item;

    final savedData = await _saveBondData(
      rootDocumentId,
      subCollectionPath,
      updatedBond.payGuid,
      updatedBond.toJson(),
    );

    return item.payGuid == null ? BondModel.fromJson(savedData) : updatedBond;
  }

  Future<BondModel> _assignBondNumber(BondModel bond) async {
    final newBondNumber = await fetchAndIncrementEntityNumber(
        rootCollectionPath, bond.bondTypeLabel??Get.find<BondTypeService>().getBondTypeByGuide(bond.payTypeGuid!).label);
    return bond.copyWith(payNumber: newBondNumber.nextNumber);
  }

  Future<Map<String, dynamic>> _saveBondData(
          String rootDocumentId,
          String subCollectionPath,
          String? bondId,
          Map<String, dynamic> data) async =>
      compoundDatabaseService.add(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: rootDocumentId,
        subCollectionPath: subCollectionPath,
        subDocumentId: bondId,
        data: data,
      );

  @override
  Future<int> countDocuments(
      {required BondTypeModel itemIdentifier,
      QueryFilter<dynamic>? countQueryFilter}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subCollectionPath = getSubCollectionPath(itemIdentifier);

    final count = await compoundDatabaseService.countDocuments(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      countQueryFilter: countQueryFilter,
    );

    return count;
  }

  @override
  Future<Map<BondTypeModel, List<BondModel>>> fetchAllNested(
      {required List<BondTypeModel> itemIdentifiers}) async {
    final bondsByType = <BondTypeModel, List<BondModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final bondTypeModel in itemIdentifiers) {
      fetchTasks.add(
        fetchAll(itemIdentifier: bondTypeModel).then((result) {
          bondsByType[bondTypeModel] = result;
        }),
      );
    }
    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return bondsByType;
  }

  @override
  Future<Map<BondTypeModel, List<BondModel>>> saveAllNested({
    required List<BondTypeModel> itemIdentifiers,
    required List<BondModel> items,
    void Function(double progress)? onProgress,
  }) async {
    final bondsByType = <BondTypeModel, List<BondModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final bondType in itemIdentifiers) {
      fetchTasks.add(
        saveAll(
                itemIdentifier: bondType,
                items: items
                    .where(
                      (bond) => bond.payTypeGuid == bondType.typeGuide,
                    )
                    .toList())
            .then((result) {
          bondsByType[bondType] = result;
        }),
      );
    }

    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return bondsByType;
  }

  @override
  Future<List<BondModel>> saveAll(
      {required List<BondModel> items,
      required BondTypeModel itemIdentifier}) async {
    final rootDocumentId = getRootDocumentId(itemIdentifier);
    final subCollectionPath = getSubCollectionPath(itemIdentifier);

    final savedData = await compoundDatabaseService.addAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      items: items.map((item) {
        return {
          ...item.toJson(),
          'docId': item.payGuid,
        };
      }).toList(),
    );

    return savedData.map(BondModel.fromJson).toList();
  }

  @override
  Future<double> fetchMetaData(
      {required String id, required BondTypeModel itemIdentifier}) {
    // TODO: implement fetchMetaData
    throw UnimplementedError();
  }
}
