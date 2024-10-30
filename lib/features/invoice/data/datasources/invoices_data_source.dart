import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/classes/datasources/firebase_datasource_base.dart';
import '../../../../core/network/error/error_handler.dart';
import '../../../../core/network/error/failure.dart';
import '../models/invoice_model.dart';

class PatternsDataSource implements FirebaseDatasourceBase<InvoiceModel> {
  final FirebaseFirestore _firestore;
  final String _collection = 'bill_types'; // Collection name in Firestore

  PatternsDataSource(this._firestore);

  @override
  Future<List<InvoiceModel>> fetchAll() async {
    final snapshot = await _firestore.collection(_collection).get();
    final invoices = snapshot.docs.map((doc) => InvoiceModel.fromJson(doc.data())).toList();
    return invoices;
  }

  @override
  Future<InvoiceModel> fetchById(String id) async {
    final doc = await _firestore.collection(_collection).doc(id).get();
    if (doc.exists) {
      final invoice = InvoiceModel.fromJson(doc.data() as Map<String, dynamic>);
      return invoice;
    } else {
      throw Failure(ResponseCode.NOT_FOUND, 'Bill not found');
    }
  }

  @override
  Future<void> save(InvoiceModel invoice) async {
    final collection = _firestore.collection(_collection);
    if (invoice.id == null) {
      // Create a new document and set its ID in the model
      final newDocRefId = collection.doc().id;
      await collection.doc(newDocRefId).set(invoice.copyWith(id: newDocRefId).toJson());
    } else {
      // Update the existing document
      await collection.doc(invoice.id).set(invoice.toJson());
    }
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }
}
