import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/compound_datasource_base.dart';
import 'package:ba3_bs/features/accounts/data/models/account_model.dart';

import '../../../../../core/models/query_filter.dart';
import '../../../../bond/data/models/entry_bond_model.dart';

class AccountsStatementsDatasource extends CompoundDatasourceBase<EntryBondItemModel, AccountEntity> {
  AccountsStatementsDatasource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bills", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.accountsStatements; // Collection name in Firestore

  @override
  Future<List<EntryBondItemModel>> fetchAll({required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
    );

    final entryBondItems = data.map((item) => EntryBondItemModel.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<List<EntryBondItemModel>> fetchWhere<V>(
      {required AccountEntity itemTypeModel, required String field, required V value, DateFilter? dateFilter}) async {
    final data = await compoundDatabaseService.fetchWhere(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: getRootDocumentId(itemTypeModel),
        subCollectionPath: getSubCollectionPath(itemTypeModel),
        field: field,
        value: value,
        dateFilter: dateFilter);

    final entryBondItems = data.map((item) => EntryBondItemModel.fromJson(item)).toList();

    return entryBondItems;
  }

  @override
  Future<EntryBondItemModel> fetchById({required String id, required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: id,
    );

    return EntryBondItemModel.fromJson(data);
  }

  @override
  Future<void> delete({required EntryBondItemModel item}) async {
    final rootDocumentId = getRootDocumentId(item.account);
    final subcollectionPath = getSubCollectionPath(item.account);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subcollectionPath,
      subDocumentId: item.originId,
    );
  }

  @override
  Future<EntryBondItemModel> save({required EntryBondItemModel item}) async {
    final rootDocumentId = getRootDocumentId(item.account);
    final subCollectionPath = getSubCollectionPath(item.account);

    final savedData = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      subDocumentId: item.originId,
      data: item.toJson(),
    );

    return EntryBondItemModel.fromJson(savedData);
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
  Future<Map<AccountEntity, List<EntryBondItemModel>>> fetchAllNested({required List<AccountEntity> itemTypes}) async {
    final billsByType = <AccountEntity, List<EntryBondItemModel>>{};

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
  Future<Map<AccountEntity, List<EntryBondItemModel>>> saveAllNested(
      {required List<AccountEntity> itemTypes, required List<EntryBondItemModel> items}) async {
    final billsByType = <AccountEntity, List<EntryBondItemModel>>{};

    final List<Future<void>> fetchTasks = [];
    // Create tasks to fetch all bills for each type

    for (final accountEntity in itemTypes) {
      fetchTasks.add(
        saveAll(
                itemTypeModel: accountEntity,
                items: items
                    .where(
                      (element) => element.account.id == accountEntity.id,
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
  Future<List<EntryBondItemModel>> saveAll(
      {required List<EntryBondItemModel> items, required AccountEntity itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final savedData = await compoundDatabaseService.saveAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subCollectionPath: subCollectionPath,
      items: items.map((item) {
        return {
          ...item.toJson(),
          'docId': item.originId,
        };
      }).toList(),
    );

    return savedData.map(EntryBondItemModel.fromJson).toList();
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
//   Future<List<EntryBondItemModel>> fetchAll(String accountId) async {
//     try {
//       final bondsCollection = _accountsStatementsCollection.doc(accountId).collection(ApiConstants.entryBondsItems);
//       final bondSnapshots = await bondsCollection.get();
//
//       if (bondSnapshots.docs.isEmpty) return [];
//
//       final List<EntryBondItemModel> entryBondItems = [];
//       for (final doc in bondSnapshots.docs) {
//         final data = doc.data() as Map<String, dynamic>?;
//
//         final itemsData = data?['items'] as List<dynamic>? ?? [];
//
//         final items = itemsData.map((item) {
//           return EntryBondItemModel.fromJson(item as Map<String, dynamic>);
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
//   Future<List<EntryBondItemModel>?> fetchById(String accountId, String bondId) async {
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
//         return EntryBondItemModel.fromJson(item as Map<String, dynamic>);
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
//   Future<Either<Failure, List<EntryBondItemModel>>> getAllBonds(String accountId) async {
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
//   Future<Either<Failure, List<EntryBondItemModel>?>> getBondById(String accountId, String bondId) async {
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
