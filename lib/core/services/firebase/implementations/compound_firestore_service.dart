import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../features/bill/data/models/bill_model.dart';
import '../../../network/api_constants.dart';

abstract class ICompoundDatabaseService<T> {
  Future<T> add({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
    required T data,
  });

  Future<List<T>> fetchAll({
    required String rootCollectionPath,
    required String rootDocumentId,
    String? subcollectionPath,
  });

  Future<T?> fetchById({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subDocumentId,
    String? subcollectionPath,
  });

  Future<void> update({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subDocumentId,
    String? subcollectionPath,
    required T data,
  });

  Future<void> delete({
    required String rootCollectionPath,
    required String rootDocumentId,
    String? subcollectionPath,
    required String subDocumentId,
  });
}

abstract class CompoundFireStoreService extends ICompoundDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<Map<String, dynamic>> add({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = _firestore
          .collection(rootCollectionPath)
          .doc(rootDocumentId)
          .collection(subcollectionPath)
          .doc(subDocumentId);
      await docRef.set(data);
      return data;
    } catch (e) {
      log('Error adding item to $rootCollectionPath: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAll({
    required String rootCollectionPath,
    required String rootDocumentId,
    String? subcollectionPath,
  }) async {
    try {
      final querySnapshot =
          _firestore.collection(rootCollectionPath).doc(rootDocumentId).collection(subcollectionPath!).get();
      return (await querySnapshot).docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error fetching all items from $rootCollectionPath: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchById({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subDocumentId,
    String? subcollectionPath,
  }) async {
    try {
      final docSnapshot = await _firestore
          .collection(rootCollectionPath)
          .doc(rootDocumentId)
          .collection(subcollectionPath!)
          .doc(subDocumentId)
          .get();
      if (!docSnapshot.exists) return null;
      return docSnapshot.data();
    } catch (e) {
      log('Error fetching item by ID from $rootCollectionPath: $e');
      rethrow;
    }
  }

  @override
  Future<void> update({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subDocumentId,
    String? subcollectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final docRef = _firestore
          .collection(rootCollectionPath)
          .doc(rootDocumentId)
          .collection(subcollectionPath!)
          .doc(subDocumentId);
      await docRef.update(data);
    } catch (e) {
      log('Error updating item in $rootCollectionPath: $e');
      rethrow;
    }
  }

  @override
  Future<void> delete({
    required String rootCollectionPath,
    required String rootDocumentId,
    String? subcollectionPath,
    required String subDocumentId,
  }) async {
    try {
      final docRef = _firestore
          .collection(rootCollectionPath)
          .doc(rootDocumentId)
          .collection(subcollectionPath!)
          .doc(subDocumentId);
      await docRef.delete();
    } catch (e) {
      log('Error deleting item from $rootCollectionPath: $e');
      rethrow;
    }
  }
}

abstract class CompoundDatasourceBase<T> {
  final ICompoundDatabaseService<Map<String, dynamic>> compoundDatabaseService;

  CompoundDatasourceBase({required this.compoundDatabaseService});

  // Path getter to be overridden by subclasses
  String get rootCollectionPath;

  Future<List<T>> fetchAll({required String rootDocumentId});

  Future<T?> fetchById({
    required String rootDocumentId,
    required String subDocumentId,
  });

  Future<void> delete({
    required String rootDocumentId,
    required String subDocumentId,
  });

  Future<T> save({
    required T item,
    bool? save,
  });
}

class BillCompoundDataSource extends CompoundDatasourceBase<BillModel> {
  BillCompoundDataSource({required super.compoundDatabaseService});

  @override
  String get rootCollectionPath => ApiConstants.billsPath; // Collection name in Firestore

  @override
  Future<List<BillModel>> fetchAll({required String rootDocumentId}) async {
    final subcollectionPath = _getSubcollectionPath(rootDocumentId);

    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subcollectionPath: subcollectionPath,
    );

    final bills = data.map((item) => BillModel.fromJson(item)).toList();

    bills.sort((a, b) => a.billDetails.billNumber!.compareTo(b.billDetails.billNumber!));

    return bills;
  }

  @override
  Future<BillModel?> fetchById({
    required String rootDocumentId,
    required String subDocumentId,
  }) async {
    final subcollectionPath = _getSubcollectionPath(rootDocumentId);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subDocumentId: subDocumentId,
      subcollectionPath: subcollectionPath,
    );

    if (data == null) return null;

    return BillModel.fromJson(data);
  }

  @override
  Future<void> delete({
    required String rootDocumentId,
    required String subDocumentId,
  }) async {
    final subcollectionPath = _getSubcollectionPath(rootDocumentId);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subcollectionPath: subcollectionPath,
      subDocumentId: subDocumentId,
    );
  }

  @override
  Future<BillModel> save({
    required BillModel item,
    bool? save,
  }) async {
    if (item.billId == null) {
      final newBillModel = await _createNewBill(bill: item);
      return newBillModel;
    } else {
      await compoundDatabaseService.update(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: getRootDocumentId(item),
        subcollectionPath: getSubcollectionPath(item),
        subDocumentId: item.billId!,
        data: item.toJson(),
      );
      return item;
    }
  }

  Future<BillModel> _createNewBill({required BillModel bill}) async {
    final newBillJson = bill.toJson();

    final data = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: getRootDocumentId(bill),
      subcollectionPath: getSubcollectionPath(bill),
      data: newBillJson,
    );

    return BillModel.fromJson(data);
  }

  static String getRootDocumentId(BillModel bill) => bill.billTypeModel.billTypeId!;

  static String getSubcollectionPath(BillModel bill) => bill.billTypeModel.fullName!;

  String _getSubcollectionPath(String rootDocumentId) {
    // Derive the subcollection path from the root document ID
    // Replace this logic if it's dynamic or based on additional factors.
    return rootDocumentId; // Placeholder logic
  }
}
