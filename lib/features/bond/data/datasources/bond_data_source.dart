import 'package:ba3_bs/features/bond/data/models/bond_record_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/network/error/error_handler.dart';
import '../../../../core/network/error/failure.dart';
import '../../../../core/services/firebase/interfaces/firebase_datasource_with_result_base.dart';

class BondsDataSource implements FirebaseDatasourceWithResultBase<BondModel> {
  final FirebaseFirestore _firestore;

  // bonds Collection name in Firestore
  final String _bondsCollection = 'bonds';

  // Collection for tracking last used invoice numbers
  final String _bondNumbersCollection = 'bond_numbers';

  BondsDataSource(this._firestore);

  @override
  Future<List<BondModel>> fetchAll() async {
    final snapshot = await _firestore.collection(_bondsCollection).get();
    final List<BondModel> bonds = snapshot.docs.map((doc) => BondModel.fromJson(doc.data())).toList();

    // Sort the list by `bondNumber` in ascending order
    bonds.sort((a, b) => a.bondCode!.compareTo(b.bondCode!));

    return bonds;
  }

  @override
  Future<BondModel> fetchById(String id) async {
    final doc = await _firestore.collection(_bondsCollection).doc(id).get();
    if (doc.exists) {
      final invoice = BondModel.fromJson(doc.data() as Map<String, dynamic>);
      return invoice;
    } else {
      throw Failure(ResponseCode.NOT_FOUND, 'bond not found');
    }
  }

  @override
  Future<BondModel> save(BondModel bondModel) async {
    if (bondModel.bondId == null) {
      // If bondId is null, create a new bond
      final newbondModel = await _createNewBond(bondModel);

      return newbondModel;
    } else {
      // Update the existing document
      await _updateExistingBond(bondModel);

      return bondModel;
    }
  }

  @override
  Future<void> delete(String id) async {
    await _firestore.collection(_bondsCollection).doc(id).delete();
  }

  Future<BondModel> _createNewBond(BondModel bond) async {
    return BondModel(bonds: []);
  /*  final newBondNumber = await _getNextBondNumber(bond.bondType!.label);

    final newDocRefId = _firestore.collection(_bondsCollection).doc().id;

    final newBond = bond.copyWith(
      bondId: newDocRefId,
      bondDetails: bond.bondDetails.copyWith(bondGuid: newDocRefId, bondNumber: newBondNumber),
    );

    final newBondJson = newBond.toJson();

    await _firestore.collection(_bondsCollection).doc(newDocRefId).set(newBondJson);

    return newBond;*/
  }

  Future<void> _updateExistingBond(BondModel bond) async =>
      await _firestore.collection(_bondsCollection).doc(bond.bondId).update(bond.toJson());

  /// Fetches the next invoice number for the given bond type and updates it atomically.
  Future<int> _getNextBondNumber(String bondType) async {
    final docRef = _firestore.collection(_bondNumbersCollection).doc(bondType);

    // Fetch the document snapshot
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // If the document does not exist, initialize it
      await docRef.set({'type': bondType, 'lastNumber': 1});
      return 1;
    }

    // Get the current last number and increment it
    final lastNumber = snapshot.data()?['lastNumber'] as int? ?? 0;
    final newNumber = lastNumber + 1;

    // Update the document with the new number
    await docRef.update({'lastNumber': newNumber});

    return newNumber;
  }
}
