
import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/compound_datasource_base.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';

import '../../../../../core/models/query_filter.dart';
import '../../../../bond/data/models/entry_bond_model.dart';

class AccountsStatementsDatasource extends CompoundDatasourceBase<EntryBondItems, AccountEntity> {
  AccountsStatementsDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bills", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.accountsStatements; // Collection name in Firestore

  @override
  Future<List<EntryBondItems>> fetchAll({required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final dataList = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
    );

    // Flatten and map data['items'] into a single list of EntryBondItems
    final entryBondItems = dataList.map((item) => EntryBondItems.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<List<EntryBondItems>> fetchWhere<V>({
    required AccountEntity itemTypeModel,
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

    // Flatten and map data['items'] into a single list of EntryBondItems
    final entryBondItems = dataList.map((item) => EntryBondItems.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<EntryBondItems> fetchById({required String id, required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: id,
    );

    return EntryBondItems.fromJson(data);
  }

  @override
  Future<void> delete({required EntryBondItems item}) async {
    final account = item.itemList.first.account;

    final rootDocumentId = getRootDocumentId(account);
    final subcollectionPath = getSubCollectionPath(account);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: item.docId ?? item.id,
    );
  }

  @override
  Future<EntryBondItems> save({required EntryBondItems item}) async {
    final account = item.itemList.first.account;

    final rootDocumentId = getRootDocumentId(account);
    final subCollectionPath = getSubCollectionPath(account);
    final savedData = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.docId ?? item.id,
      data: {'items': item.itemList.map((item) => item.toJson()).toList()},
    );

    return EntryBondItems.fromJson(savedData);
  }

  @override
  Future<int> countDocuments({required AccountEntity itemTypeModel, QueryFilter? countQueryFilter}) async {
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
  Future<Map<AccountEntity, List<EntryBondItems>>> fetchAllNested({required List<AccountEntity> itemTypes}) async {
    final billsByType = <AccountEntity, List<EntryBondItems>>{};

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
  Future<Map<AccountEntity, List<EntryBondItems>>> saveAllNested({
    required List<AccountEntity> itemTypes,
    required List<EntryBondItems> items,
    void Function(double progress)? onProgress,
  }) async {
    final billsByType = <AccountEntity, List<EntryBondItems>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final accountEntity in itemTypes) {
      fetchTasks.add(
        saveAll(
                itemTypeModel: accountEntity,
                items: items
                    .where(
                      (element) => element.itemList.first.account.id == accountEntity.id,
                    )
                    .toList())
            .then((result) {
          billsByType[accountEntity] = result;
        }),
      );
    }

    // Wait for all tasks to complete
    await Future.wait(fetchTasks);

    return billsByType;
  }

  @override
  Future<List<EntryBondItems>> saveAll({required List<EntryBondItems> items, required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final savedData = await compoundDatabaseService.saveAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      items: items.map((item) {
        return {
          ...item.toJson(),
          'docId': item.id,
        };
      }).toList(),
    );

    return savedData.map(EntryBondItems.fromJson).toList();
  }
}

// class AccountsStatementsDatasource {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   CollectionReference get _accountsStatementsCollection => _firestore.collection(ApiConstants.accountsStatements);
//
//   /// Add a new bond entry to Firestore under a specific account
//   Future<void> add(String accountId, EntryBondModel entryBond) async {
//     try {
//       final docRef = _accountsStatementsCollection
//           .doc(accountId)
//           .collection(ApiConstants.entryBondsItems)
//           .doc(entryBond.origin?.originId);
//
//       final items =
//           entryBond.items?.where((item) => item.account.id == accountId).map((item) => item.toJson()).toList() ?? [];
//
//       await docRef.set({'items': items});
//     } catch (e) {
//       throw Exception('Failed to add bond: $e');
//     }
//   }
//
//   /// Fetch all bond entries under a specific account
//   Future<List<EntryBondItems>> fetchAll(String accountId) async {
//     try {
//       final bondsCollection = _accountsStatementsCollection.doc(accountId).collection(ApiConstants.entryBondsItems);
//       final bondSnapshots = await bondsCollection.get();
//
//       if (bondSnapshots.docs.isEmpty) return [];
//
//       final List<EntryBondItems> entryBondItems = [];
//       for (final doc in bondSnapshots.docs) {
//         final data = doc.data() as Map<String, dynamic>?;
//
//         final itemsData = data?['items'] as List<dynamic>? ?? [];
//
//         final items = itemsData.map((item) {
//           return EntryBondItems.fromJson(item as Map<String, dynamic>);
//         }).toList();
//
//         entryBondItems.addAll(items);
//       }
//       return entryBondItems;
//     } catch (e) {
//       throw Exception('Failed to fetch bonds: $e');
//     }
//   }
//
//   /// Fetch a specific bond entry items under a specific account by origin id created from it
//   Future<List<EntryBondItems>?> fetchById(String accountId, String bondId) async {
//     try {
//       final docRef = _accountsStatementsCollection.doc(accountId).collection(ApiConstants.entryBondsItems).doc(bondId);
//       final docSnapshot = await docRef.get();
//
//       if (!docSnapshot.exists) return null;
//
//       final data = docSnapshot.data();
//
//       final itemsData = data?['items'] as List<dynamic>? ?? [];
//       final items = itemsData.map((item) {
//         return EntryBondItems.fromJson(item as Map<String, dynamic>);
//       }).toList();
//
//       return items;
//     } catch (e) {
//       throw Exception('Failed to fetch bond by ID: $e');
//     }
//   }
//
//   /// Update a bond entry's items under a specific account and bondId
//   Future<void> update(String accountId, String bondId, EntryBondModel entryBond) async {
//     try {
//       final docRef = _accountsStatementsCollection.doc(accountId).collection(ApiConstants.entryBondsItems).doc(bondId);
//       final items = entryBond.items?.map((item) => item.toJson()).toList() ?? [];
//       await docRef.update({'items': items});
//     } catch (e) {
//       throw Exception('Failed to update bond: $e');
//     }
//   }
//
//   /// Delete a specific bond entry under a given account by bondId
//   Future<void> delete(String accountId, String originId) async {
//     try {
//       final docRef =
//           _accountsStatementsCollection.doc(accountId).collection(ApiConstants.entryBondsItems).doc(originId);
//       await docRef.delete();
//     } catch (e) {
//       throw Exception('Failed to delete bond: $e');
//     }
//   }
//
//   /// Delete all bond entries under a specific account
//   Future<void> deleteAllBonds(String accountId) async {
//     try {
//       final bondsCollection = _accountsStatementsCollection.doc(accountId).collection(ApiConstants.entryBondsItems);
//       final bondSnapshots = await bondsCollection.get();
//
//       final batch = _firestore.batch();
//
//       for (final doc in bondSnapshots.docs) {
//         batch.delete(doc.reference);
//       }
//
//       await batch.commit();
//     } catch (e) {
//       throw Exception('Failed to delete all bonds: $e');
//     }
//   }
// }
//
// class AccountsStatementsRepository {
//   final AccountsStatementsDatasource _dataSource;
//
//   AccountsStatementsRepository(this._dataSource);
//
//   Future<Either<Failure, List<EntryBondItems>>> getAllBonds(String accountId) async {
//     try {
//       final data = await _dataSource.fetchAll(accountId);
//
//       return Right(data);
//     } catch (e) {
//       log('Error in getAllBonds: $e');
//       return Left(ErrorHandler(e).failure);
//     }
//   }
//
//   Future<Either<Failure, List<EntryBondItems>?>> getBondById(String accountId, String bondId) async {
//     try {
//       final data = await _dataSource.fetchById(accountId, bondId);
//
//       return Right(data);
//     } catch (e) {
//       log('Error in getBondById: $e');
//       return Left(ErrorHandler(e).failure);
//     }
//   }
//
//   Future<Either<Failure, Unit>> addBond(String accountId, EntryBondModel bond) async {
//     try {
//       await _dataSource.add(accountId, bond);
//       return const Right(unit);
//     } catch (e) {
//       log('Error in addBond: $e');
//       return Left(ErrorHandler(e).failure);
//     }
//   }
//
//   Future<Either<Failure, Unit>> updateBond(String accountId, String bondId, EntryBondModel bond) async {
//     try {
//       await _dataSource.update(accountId, bondId, bond);
//       return const Right(unit);
//     } catch (e) {
//       log('Error in updateBond: $e');
//       return Left(ErrorHandler(e).failure);
//     }
//   }
//
//   Future<Either<Failure, Unit>> deleteBond(String accountId, String originId) async {
//     try {
//       await _dataSource.delete(accountId, originId);
//       return const Right(unit);
//     } catch (e) {
//       log('Error in deleteBond: $e');
//       return Left(ErrorHandler(e).failure);
//     }
//   }
//
//   Future<Either<Failure, Unit>> deleteAllBonds(String accountId) async {
//     try {
//       await _dataSource.deleteAllBonds(accountId);
//       return const Right(unit);
//     } catch (e) {
//       log('Error in deleteAllBonds: $e');
//       return Left(ErrorHandler(e).failure);
//     }
//   }
// }
