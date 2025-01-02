import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../models/count_query_filter.dart';
import '../../../../models/date_filter.dart';
import '../../interfaces/i_compound_database_service.dart';

class CompoundFireStoreService extends ICompoundDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Map<String, dynamic>>> fetchAll({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
  }) async {
    final querySnapshot =
        _firestore.collection(rootCollectionPath).doc(rootDocumentId).collection(subcollectionPath).get();
    return (await querySnapshot).docs.map((doc) => doc.data()).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> fetchWhere<V>({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    required String field,
    required V value,
    DateFilter? dateFilter,
  }) async {
    // Build the base query
    Query<Map<String, dynamic>> query = _firestore
        .collection(rootCollectionPath)
        .doc(rootDocumentId)
        .collection(subcollectionPath)
        .where(field, isEqualTo: value);

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
  Future<Map<String, dynamic>> fetchById({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
  }) async {
    final docSnapshot = await _firestore
        .collection(rootCollectionPath)
        .doc(rootDocumentId)
        .collection(subcollectionPath)
        .doc(subDocumentId)
        .get();
    if (docSnapshot.exists) {
      return docSnapshot.data()!;
    } else {
      throw Exception('Document not found');
    }
  }

  @override
  Future<Map<String, dynamic>> add({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
    required Map<String, dynamic> data,
  }) async {
    if (subDocumentId == null) {
      final docRef = _firestore.collection(rootCollectionPath).doc(rootDocumentId).collection(subcollectionPath).doc();

      data['docId'] = docRef.id;

      await docRef.set(data);
    } else {
      await _firestore
          .collection(rootCollectionPath)
          .doc(rootDocumentId)
          .collection(subcollectionPath)
          .doc(subDocumentId)
          .set(data);
    }

    return data;
  }

  @override
  Future<void> update({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
    required Map<String, dynamic> data,
  }) async {
    final docRef =
        _firestore.collection(rootCollectionPath).doc(rootDocumentId).collection(subcollectionPath).doc(subDocumentId);
    await docRef.update(data);
  }

  @override
  Future<void> delete({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    String? subDocumentId,
  }) async {
    final docRef =
        _firestore.collection(rootCollectionPath).doc(rootDocumentId).collection(subcollectionPath).doc(subDocumentId);
    await docRef.delete();
  }

  @override
  Future<int> countDocuments({
    required String rootCollectionPath,
    required String rootDocumentId,
    required String subcollectionPath,
    CountQueryFilter? countQueryFilter,
  }) async {
    // Start with the base query as a Query<Map<String, dynamic>>
    Query<Map<String, dynamic>> query =
        _firestore.collection(rootCollectionPath).doc(rootDocumentId).collection(subcollectionPath);

    // Apply the filter if provided
    if (countQueryFilter != null) {
      query = query.where(
        countQueryFilter.field,
        isEqualTo: countQueryFilter.value,
      );
    }

    // Convert the query to a count query
    final countQuery = query.count();

    // Execute the count query
    final countSnapshot = await countQuery.get();

    // Return the count
    return countSnapshot.count ?? 0;
  }
}
