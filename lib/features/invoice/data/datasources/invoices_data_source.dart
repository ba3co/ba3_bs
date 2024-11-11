import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/classes/base/i_firebase_datasource.dart';
import '../../../../core/network/error/error_handler.dart';
import '../../../../core/network/error/failure.dart';
import '../models/bill_model.dart';

class InvoicesDataSource implements IFirebaseDatasource<BillModel> {
  final FirebaseFirestore _firestore;
  final String _collection = 'bills'; // Collection name in Firestore

  InvoicesDataSource(this._firestore);

  @override
  Future<List<BillModel>> fetchAll() async {
    final snapshot = await _firestore.collection(_collection).get();
    final invoices = snapshot.docs.map((doc) => BillModel.fromJson(doc.data())).toList();
    return invoices;
  }

  @override
  Future<BillModel> fetchById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      final invoice = BillModel.fromJson(doc.data() as Map<String, dynamic>);
      return invoice;
    } else {
      throw Failure(ResponseCode.NOT_FOUND, 'Bill not found');
    }
  }

  @override
  Future<void> save(BillModel bill) async {
    final collection = _firestore.collection(_collection);
    if (bill.billId == null) {
      // Create a new document and set its ID in the model
      final newDocRefId = collection.doc().id;
      await collection.doc(newDocRefId).set(
          bill.copyWith(billId: newDocRefId, billDetails: bill.billDetails.copyWith(billGuid: newDocRefId)).toJson());
    } else {
      // Update the existing document
      await collection.doc(bill.billId).update(bill.toJson());
    }
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
