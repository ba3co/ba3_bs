import 'dart:developer';

import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../features/bond/data/models/entry_bond_model.dart';
import '../network/error/error_handler.dart';
import '../network/error/failure.dart';

class AccountsStatementsDataSource {
  AccountsStatementsDataSource();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _accountsStatementsCollection => _firestore.collection(ApiConstants.accountsStatements);

  /// Add a new bond entry to Firestore under a specific account
  Future<void> add(String accountId, EntryBondModel entryBond) async {
    try {
      final docRef = _accountsStatementsCollection.doc(accountId).collection('bonds').doc(entryBond.id);
      final items =
          entryBond.items?.where((item) => item.accountId == accountId).map((item) => item.toJson()).toList() ?? [];
      await docRef.set({'items': items});
    } catch (e) {
      throw Exception('Failed to add bond: $e');
    }
  }

  /// Fetch all bond entries under a specific account
  Future<List<EntryBondItemModel>> fetchAll(String accountId) async {
    try {
      final bondsCollection = _accountsStatementsCollection.doc(accountId).collection('bonds');
      final bondSnapshots = await bondsCollection.get();

      if (bondSnapshots.docs.isEmpty) return [];

      final List<EntryBondItemModel> entryBondItems = [];
      for (var doc in bondSnapshots.docs) {
        final data = doc.data() as Map<String, dynamic>?;

        final itemsData = data?['items'] as List<dynamic>? ?? [];
        final items = itemsData.map((item) {
          return EntryBondItemModel.fromJson(item as Map<String, dynamic>);
        }).toList();

        entryBondItems.addAll(items);
      }

      return entryBondItems;
    } catch (e) {
      throw Exception('Failed to fetch bonds: $e');
    }
  }

  /// Fetch a specific bond entry under a specific account by bondId
  Future<EntryBondModel?> fetchById(String accountId, String bondId) async {
    try {
      final docRef = _accountsStatementsCollection.doc(accountId).collection('bonds').doc(bondId);
      final docSnapshot = await docRef.get();

      if (!docSnapshot.exists) return null;

      final data = docSnapshot.data();

      final itemsData = data?['items'] as List<dynamic>? ?? [];
      final items = itemsData.map((item) {
        return EntryBondItemModel.fromJson(item as Map<String, dynamic>);
      }).toList();

      return EntryBondModel(id: bondId, items: items);
    } catch (e) {
      throw Exception('Failed to fetch bond by ID: $e');
    }
  }

  /// Update a bond entry's items under a specific account and bondId
  Future<void> update(String accountId, String bondId, EntryBondModel entryBond) async {
    try {
      final docRef = _accountsStatementsCollection.doc(accountId).collection('bonds').doc(bondId);
      final items = entryBond.items?.map((item) => item.toJson()).toList() ?? [];
      await docRef.update({'items': items});
    } catch (e) {
      throw Exception('Failed to update bond: $e');
    }
  }

  /// Delete a specific bond entry under a given account by bondId
  Future<void> delete(String accountId, String bondId) async {
    try {
      final docRef = _accountsStatementsCollection.doc(accountId).collection('bonds').doc(bondId);
      await docRef.delete();
    } catch (e) {
      throw Exception('Failed to delete bond: $e');
    }
  }

  /// Delete all bond entries under a specific account
  Future<void> deleteAllBonds(String accountId) async {
    try {
      final bondsCollection = _accountsStatementsCollection.doc(accountId).collection('bonds');
      final bondSnapshots = await bondsCollection.get();

      final batch = _firestore.batch();
      for (var doc in bondSnapshots.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all bonds: $e');
    }
  }
}

class AccountsStatementsRepository {
  final AccountsStatementsDataSource _dataSource;

  AccountsStatementsRepository(this._dataSource);

  Future<Either<Failure, List<EntryBondItemModel>>> getAllBonds(String accountId) async {
    try {
      final data = await _dataSource.fetchAll(accountId);

      if (data.isEmpty) return const Right([]);

      return Right(data);
    } catch (e) {
      log('Error in getAllBonds: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, EntryBondModel?>> getBondById(String accountId, String bondId) async {
    try {
      final data = await _dataSource.fetchById(accountId, bondId);

      return Right(data);
    } catch (e) {
      log('Error in getBondById: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> addBond(String accountId, EntryBondModel bond) async {
    try {
      await _dataSource.add(accountId, bond);
      return const Right(unit);
    } catch (e) {
      log('Error in addBond: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> updateBond(String accountId, String bondId, EntryBondModel bond) async {
    try {
      await _dataSource.update(accountId, bondId, bond);
      return const Right(unit);
    } catch (e) {
      log('Error in updateBond: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> deleteBond(String accountId, String bondId) async {
    try {
      await _dataSource.delete(accountId, bondId);
      return const Right(unit);
    } catch (e) {
      log('Error in deleteBond: $e');
      return Left(ErrorHandler(e).failure);
    }
  }

  Future<Either<Failure, Unit>> deleteAllBonds(String accountId) async {
    try {
      await _dataSource.deleteAllBonds(accountId);
      return const Right(unit);
    } catch (e) {
      log('Error in deleteAllBonds: $e');
      return Left(ErrorHandler(e).failure);
    }
  }
}
