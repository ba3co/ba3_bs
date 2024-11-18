import 'package:ba3_bs/core/services/firebase/abstract/firebase_datasource_with_result_base.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/error/error_handler.dart';
import '../../../../core/network/error/failure.dart';
import '../models/bill_model.dart';

class BillsDataSource implements FirebaseDatasourceWithResultBase<BillModel> {
  final FirebaseFirestore _firestore;

  // Bills Collection name in Firestore
  final String _billsCollection = 'bills';

  // Collection for tracking last used invoice numbers
  final String _billNumbersCollection = 'bill_numbers';

  BillsDataSource(this._firestore);

  @override
  Future<List<BillModel>> fetchAll() async {
    final snapshot = await _firestore.collection(_billsCollection).get();
    final invoices = snapshot.docs.map((doc) => BillModel.fromJson(doc.data())).toList();

    // Sort the list by `billNumber` in ascending order
    invoices.sort((a, b) => a.billDetails.billNumber!.compareTo(b.billDetails.billNumber!));

    return invoices;
  }

  @override
  Future<BillModel> fetchById(String id) async {
    final doc = await _firestore.collection(_billsCollection).doc(id).get();
    if (doc.exists) {
      final invoice = BillModel.fromJson(doc.data() as Map<String, dynamic>);
      return invoice;
    } else {
      throw Failure(ResponseCode.NOT_FOUND, 'Bill not found');
    }
  }

  @override
  Future<BillModel> save(BillModel billModel) async {
    if (billModel.billId == null) {
      // If billId is null, create a new bill
      final newBillModel = await _createNewBill(billModel);

      return newBillModel;
    } else {
      // Update the existing document
      await _updateExistingBill(billModel);

      return billModel;
    }
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_billsCollection).doc(id).delete();
  }

  Future<BillModel> _createNewBill(BillModel bill) async {
    final newInvoiceNumber = await _getNextBillNumber(bill.billTypeModel.billTypeLabel!);

    final newDocRefId = _firestore.collection(_billsCollection).doc().id;

    final newBill = bill.copyWith(
      billId: newDocRefId,
      billDetails: bill.billDetails.copyWith(billGuid: newDocRefId, billNumber: newInvoiceNumber),
    );

    final newBillJson = newBill.toJson();

    await _firestore.collection(_billsCollection).doc(newDocRefId).set(newBillJson);

    return newBill;
  }

  Future<void> _updateExistingBill(BillModel bill) async =>
      await _firestore.collection(_billsCollection).doc(bill.billId).update(bill.toJson());

  /// Fetches the next invoice number for the given bill type and updates it atomically.
  Future<int> _getNextBillNumber(String billType) async {
    final docRef = _firestore.collection(_billNumbersCollection).doc(billType);

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        // If the document does not exist, initialize it
        transaction.set(docRef, {'type': billType, 'lastNumber': 1});
        return 1;
      }

      // Get the current last number and increment it
      final lastNumber = snapshot.data()?['lastNumber'] as int? ?? 0;
      final newNumber = lastNumber + 1;

      // Update the document with the new number
      transaction.update(docRef, {'lastNumber': newNumber});
      return newNumber;
    });
  }
}
