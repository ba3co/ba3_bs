import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/compound_datasource_base.dart';

import '../../../../../core/models/query_filter.dart';
import '../../models/mat_statement/mat_statement_item.dart';

class MaterialsStatementsDatasource extends CompoundDatasourceBase<MatStatementItemModel, String> {
  MaterialsStatementsDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bills", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.materialsStatements; // Collection name in Firestore

  @override
  Future<List<MatStatementItemModel>> fetchAll({required String itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final dataList = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
    );

    // Flatten and map data['items'] into a single list of MatStatementItemModel
    final entryBondItems = dataList.map((item) => MatStatementItemModel.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<List<MatStatementItemModel>> fetchWhere<V>({
    required String itemTypeModel,
    required String field,
    required V value,
    DateFilter? dateFilter,
  }) async {
    final dataList = await compoundDatabaseService.fetchWhere(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: getRootDocumentId(itemTypeModel),
      subCollectionPath: getSubCollectionPath(itemTypeModel),
      field: field,
      value: value,
      dateFilter: dateFilter,
    );

    // Flatten and map data['items'] into a single list of MatStatementItemModel
    final entryBondItems = dataList.map((item) => MatStatementItemModel.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<MatStatementItemModel> fetchById({required String id, required String itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: id,
    );

    return MatStatementItemModel.fromJson(data);
  }

  @override
  Future<void> delete({required MatStatementItemModel item}) async {
    final String id = item.id!;

    final rootDocumentId = getRootDocumentId(id);
    final subcollectionPath = getSubCollectionPath(id);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: item.matOrigin?.originId,
    );
  }

  @override
  Future<MatStatementItemModel> save({required MatStatementItemModel item}) async {
    final String id = item.id!;

    final rootDocumentId = getRootDocumentId(id);
    final subCollectionPath = getSubCollectionPath(id);

    final savedData = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.matOrigin?.originId,
      data: item.toJson(),
    );

    return MatStatementItemModel.fromJson(savedData);
  }

  @override
  Future<int> countDocuments({required String itemTypeModel, QueryFilter? countQueryFilter}) async {
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
  Future<Map<String, List<MatStatementItemModel>>> fetchAllNested({required List<String> itemTypes}) async {
    final billsByType = <String, List<MatStatementItemModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final billTypeModel in itemTypes) {
      fetchTasks.add(
        fetchAll(itemTypeModel: billTypeModel).then((result) {
          billsByType[billTypeModel] = result;
        }),
      );
    }
    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return billsByType;
  }

  @override
  Future<Map<String, List<MatStatementItemModel>>> saveAllNested({
    required List<String> itemTypes,
    required List<MatStatementItemModel> items,
    void Function(double progress)? onProgress,
  }) async {
    final billsByType = <String, List<MatStatementItemModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final matId in itemTypes) {
      fetchTasks.add(
        saveAll(
                itemTypeModel: matId,
                items: items
                    .where(
                      (element) => element.id == matId,
                    )
                    .toList())
            .then((result) {
          billsByType[matId] = result;
        }),
      );
    }

    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return billsByType;
  }

  @override
  Future<List<MatStatementItemModel>> saveAll(
      {required List<MatStatementItemModel> items, required String itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final savedData = await compoundDatabaseService.saveAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      items: items.map((item) {
        return item.toJson();
      }).toList(),
    );

    return savedData.map(MatStatementItemModel.fromJson).toList();
  }
}
