import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/base_classes/interface_data_source.dart';
import '../../../../core/network/error/error_handler.dart';
import '../../../../core/network/error/failure.dart';
import '../models/bill_type_model.dart';

class PatternsDataSource implements IDataSource<DocumentSnapshot<Map<String, dynamic>>, BillTypeModel> {
  final FirebaseFirestore _firestore;
  final String _collection = 'bill_types'; // Collection name in Firestore

  PatternsDataSource(this._firestore);

  @override
  Future<List<DocumentSnapshot<Map<String, dynamic>>>> fetchAll() async {
    final snapshot = await _firestore.collection(_collection).get();
    return snapshot.docs;
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> fetchById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      return doc;
    } else {
      throw Failure(ResponseCode.NOT_FOUND, 'Bill type not found');
    }
  }

  @override
  Future<void> save(BillTypeModel billType) async {
    final collection = _firestore.collection(_collection);
    if (billType.id == null) {
      // Create a new document and set its ID in the model
      final newDocRefId = collection.doc().id;
      await collection.doc(newDocRefId).set(billType.copyWith(id: newDocRefId).toJson());
    } else {
      // Update the existing document
      await collection.doc(billType.id).set(billType.toJson());
    }
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
