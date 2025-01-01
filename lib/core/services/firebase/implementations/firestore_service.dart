// Firebase-Specific Implementation
import 'dart:developer';

import 'package:ba3_bs/core/services/firebase/interfaces/i_database_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/date_filter.dart';

// FirebaseFirestoreService Implementation
class FireStoreService extends IDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAll({required String path}) async {
    final snapshot = await _firestore.collection(path).get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWhere<V>(
      {required String path, required String field, required V value, DateFilter? dateFilter}) async {
    // Build the base query
    Query<Map<String, dynamic>> query = _firestore.collection(path).where(field, isEqualTo: value);

    // Apply date filter if provided
    if (dateFilter != null) {
      query = _applyDateFilter(query, dateFilter);
    }

    // Execute the query and return results
    final snapshot = await query.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

// Helper method to apply the date filter to the query
  Query<Map<String, dynamic>> _applyDateFilter(Query<Map<String, dynamic>> query, DateFilter dateFilter) {
    // The start date/time for the range filter (inclusive).
    final start = dateFilter.range.start;

    // Adjust the end date to include the entire day up to the last millisecond (23:59:59.999).
    // This ensures that timestamps on the end date are not unintentionally excluded.
    final end =
        DateTime(dateFilter.range.end.year, dateFilter.range.end.month, dateFilter.range.end.day, 23, 59, 59, 999);

    // Apply the date range filters to the query.
    // - Greater than or equal to the start ensures we capture all entries from the start date onward.
    // - Less than or equal to the adjusted end ensures we include all entries up to the end of the specified date.
    return query
        .where(dateFilter.dateFieldName, isGreaterThanOrEqualTo: start)
        .where(dateFilter.dateFieldName, isLessThanOrEqualTo: end);
  }

  @override
  Future<Map<String, dynamic>> fetchById({required String path, String? documentId}) async {
    final doc = await _firestore.collection(path).doc(documentId).get();
    if (doc.exists) {
      return doc.data()!;
    } else {
      throw Exception('Document not found');
    }
  }

  @override
  Future<void> delete({required String path, String? documentId}) async {
    await _firestore.collection(path).doc(documentId).delete();
  }

  @override
  Future<Map<String, dynamic>> add(
      {required String path, String? documentId, required Map<String, dynamic> data}) async {
    if (documentId == null) {
      final docId = _firestore.collection(path).doc().id;

      data['docId'] = docId;

      await _firestore.collection(path).doc(docId).set(data);
    } else {
      await _firestore.collection(path).doc(documentId).set(data);
    }

    return data;
  }

  @override
  Future<void> update({required String path, String? documentId, required Map<String, dynamic> data}) async {
    log('update path $path, $documentId');
    await _firestore.collection(path).doc(documentId).update(data);
  }

  @override
  Future<List<Map<String, dynamic>>> addAll({
    required String path,
    required List<Map<String, dynamic>> data,
  }) async {
    final batch = _firestore.batch();
    final addedItems = <Map<String, dynamic>>[];

    for (final item in data) {
      // Ensure the document ID is set
      final docId = item.putIfAbsent('docId', () => _firestore.collection(path).doc().id);

      // Add the item to the batch
      final docRef = _firestore.collection(path).doc(docId);
      batch.set(docRef, item);

      // Collect the processed item
      addedItems.add(item);
    }

    await batch.commit();
    return addedItems;
  }
}
