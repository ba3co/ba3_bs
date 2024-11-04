import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/classes/datasources/firebase_datasource_base.dart';
import '../../../../core/network/error/error_handler.dart';
import '../../../../core/network/error/failure.dart';
import '../models/bill_type_model.dart';

class PatternsDataSource implements FirebaseDatasourceBase<BillTypeModel> {
  final FirebaseFirestore _firestore;
  final String _collection = 'bill_types'; // Collection name in Firestore

  PatternsDataSource(this._firestore);

  @override
  Future<List<BillTypeModel>> fetchAll() async {
    final snapshot = await _firestore.collection(_collection).get();
    final billTypes = snapshot.docs.map((doc) => BillTypeModel.fromJson(doc.data())).toList();
    return billTypes;
  }

  @override
  Future<BillTypeModel> fetchById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      final billType = BillTypeModel.fromJson(doc.data() as Map<String, dynamic>);
      return billType;
    } else {
      throw Failure(ResponseCode.NOT_FOUND, 'Bill type not found');
    }
  }

  @override
  Future<void> save(BillTypeModel billType) async {
    final collection = _firestore.collection(_collection);

    if (billType.billTypeId == null) {
      // Create a new document and set its ID in the model
      final newDocRefId = collection.doc().id;
      await collection.doc(newDocRefId).set(billType.copyWith(billTypeId: newDocRefId).toJson());
    } else {
      // Update the existing document
      await collection.doc(billType.billTypeId).set(billType.toJson());
    }
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
