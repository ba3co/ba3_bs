import 'dart:developer';

import 'package:ba3_bs/features/changes/data/model/changes_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase/interfaces/listen_datasource.dart';

/// Implementation of ListenDatasource
class ChangesListenDatasource extends ListenableDatasource<ChangesModel> {
  ChangesListenDatasource({required super.databaseService});

  /// Subscribe to changes for a specific document ID
  @override
  Stream<ChangesModel> subscribeToDoc({required String documentId}) {
    return databaseService
        .subscribeToDoc(path: path, documentId: documentId)
        .map((data) => ChangesModel.fromJson(data));
  }

  @override
  String get path => 'changes'; // Collection name in Firestore

  /// Fetch all changes
  @override
  Future<List<ChangesModel>> fetchAll() async {
    final data = await databaseService.fetchAll(path: path);
    return data.map((item) => ChangesModel.fromJson(item)).toList();
  }

  /// Fetch a change by its ID

  @override
  Future<ChangesModel> fetchById(String id) async {
    final item = await databaseService.fetchById(path: path, documentId: id);
    return ChangesModel.fromJson(item);
  }

  /// Save or update a change
  @override
  Future<ChangesModel> save(ChangesModel item) async {
    final data = await databaseService.add(
      path: path,
      documentId: item.targetUserId,
      data: item.toJson(),
    );
    return ChangesModel.fromJson(data);
  }

  /// Add all changes using a batch operation
  // @override
  // Future<List<ChangesModel>> saveAll(List<ChangesModel> items) async {
  //   final data = await databaseService.addAll(
  //     path: path,
  //     data: items.map((item) => {...item.toJson(), 'docId': item.targetUserId}).toList(),
  //   );
  //   return data.map((item) => ChangesModel.fromJson(item)).toList();
  // }
  @override
  Future<List<ChangesModel>> saveAll(List<ChangesModel> items) async {
    final batch = FirebaseFirestore.instance.batch();

    for (var item in items) {
      final docId = item.targetUserId;

      // Loop through each changeItem and apply arrayUnion
      for (var collection in item.changeItems.keys) {
        log('collection ${collection.name}');

        final changes = item.changeItems[collection]!;

        final docRef = FirebaseFirestore.instance.collection(path).doc(docId);

        // Check if the document exists
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          // If document doesn't exist, create it with initial empty data
          batch.set(docRef, {
            'docId': docId,
            'changeItems': {
              collection.name: changes.map((changeItem) => changeItem.toJson()).toList(),
            }
          });
        } else {
          // If document exists, update it with arrayUnion
          batch.update(
            docRef,
            {
              'changeItems.${collection.name}': FieldValue.arrayUnion(
                changes.map((changeItem) => changeItem.toJson()).toList(),
              ),
            },
          );
        }
      }
    }

    // Commit the batch write operation
    await batch.commit();

    // Fetch and return the updated list of items
    final List<Map<String, dynamic>> updatedData = await databaseService.fetchAll(path: path);

    return updatedData.map((item) => ChangesModel.fromJson(item)).toList();
  }

  /// Delete a change by ID
  @override
  Future<void> delete(String id) async {
    await databaseService.delete(path: path, documentId: id);
  }
}
