import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/date_filter.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/i_database_service.dart';

class FirestoreCompoundCollectionsService extends IDatabaseService<Map<String, dynamic>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Add a new entry to Firestore under a specific account
  Future<void> addToSubcollection(
      {required String collectionPath,
        required String documentId,
        required String subcollectionPath,
        required String subDocumentId,
        required Map<String, dynamic> data}) async {
    try {
      final docRef = _firestore
          .collection(collectionPath)
          .doc(documentId)
          .collection(subcollectionPath)
          .doc(subDocumentId);
      await docRef.set(data);
    } catch (e) {
      throw Exception('Failed to add entry: $e');
    }
  }

  /// Fetch all entries from a subcollection
  Future<List<Map<String, dynamic>>> fetchAllFromSubcollection(
      {required String collectionPath,
        required String documentId,
        required String subcollectionPath}) async {
    try {
      final subcollectionRef = _firestore
          .collection(collectionPath)
          .doc(documentId)
          .collection(subcollectionPath);
      final snapshot = await subcollectionRef.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      throw Exception('Failed to fetch entries: $e');
    }
  }

  /// Fetch a specific entry from a subcollection by its ID
  Future<Map<String, dynamic>?> fetchByIdFromSubcollection(
      {required String collectionPath,
        required String documentId,
        required String subcollectionPath,
        required String subDocumentId}) async {
    try {
      final docRef = _firestore
          .collection(collectionPath)
          .doc(documentId)
          .collection(subcollectionPath)
          .doc(subDocumentId);
      final docSnapshot = await docRef.get();
      return docSnapshot.data();
    } catch (e) {
      throw Exception('Failed to fetch entry by ID: $e');
    }
  }

  /// Update a specific entry in a subcollection
  Future<void> updateInSubcollection(
      {required String collectionPath,
        required String documentId,
        required String subcollectionPath,
        required String subDocumentId,
        required Map<String, dynamic> data}) async {
    try {
      final docRef = _firestore
          .collection(collectionPath)
          .doc(documentId)
          .collection(subcollectionPath)
          .doc(subDocumentId);
      await docRef.update(data);
    } catch (e) {
      throw Exception('Failed to update entry: $e');
    }
  }

  /// Delete a specific entry from a subcollection
  Future<void> deleteFromSubcollection(
      {required String collectionPath,
        required String documentId,
        required String subcollectionPath,
        required String subDocumentId}) async {
    try {
      final docRef = _firestore
          .collection(collectionPath)
          .doc(documentId)
          .collection(subcollectionPath)
          .doc(subDocumentId);
      await docRef.delete();
    } catch (e) {
      throw Exception('Failed to delete entry: $e');
    }
  }

  /// Delete all entries from a subcollection
  Future<void> deleteAllFromSubcollection(
      {required String collectionPath,
        required String documentId,
        required String subcollectionPath}) async {
    try {
      final subcollectionRef = _firestore
          .collection(collectionPath)
          .doc(documentId)
          .collection(subcollectionPath);
      final snapshot = await subcollectionRef.get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all entries: $e');
    }
  }
}
