// BillsDataSource Implementation
import 'package:ba3_bs/core/models/date_filter.dart';
import 'package:ba3_bs/core/network/api_constants.dart';
import 'package:ba3_bs/core/services/firebase/interfaces/compound_datasource_base.dart';

import '../../../../core/models/count_query_filter.dart';
import '../../../patterns/data/models/bill_type_model.dart';
import '../models/bill_model.dart';

class BillCompoundDataSource extends CompoundDatasourceBase<BillModel, BillTypeModel> {
  BillCompoundDataSource({required super.compoundDatabaseService});

  // Parent Collection (e.g., "bills", "bonds")
  @override
  String get rootCollectionPath => ApiConstants.billsPath; // Collection name in Firestore

  @override
  Future<List<BillModel>> fetchAll({required BillTypeModel itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchAll(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subcollectionPath: subcollectionPath,
    );

    final bills = data.map((item) => BillModel.fromJson(item)).toList();

    bills.sort((a, b) => a.billDetails.billNumber!.compareTo(b.billDetails.billNumber!));

    return bills;
  }

  @override
  Future<List<BillModel>> fetchWhere<V>(
      {required BillTypeModel itemTypeModel, required String field, required V value, DateFilter? dateFilter}) async {
    final data = await compoundDatabaseService.fetchWhere(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: getRootDocumentId(itemTypeModel),
        subcollectionPath: getSubCollectionPath(itemTypeModel),
        field: field,
        value: value,
        dateFilter: dateFilter);

    final users = data.map((item) => BillModel.fromJson(item)).toList();

    return users;
  }

  @override
  Future<BillModel> fetchById({required String id, required BillTypeModel itemTypeModel}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subcollectionPath = getSubCollectionPath(itemTypeModel);

    final data = await compoundDatabaseService.fetchById(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subcollectionPath: subcollectionPath,
      subDocumentId: id,
    );

    return BillModel.fromJson(data);
  }

  @override
  Future<void> delete({required BillModel item}) async {
    final rootDocumentId = getRootDocumentId(item.billTypeModel);
    final subcollectionPath = getSubCollectionPath(item.billTypeModel);

    await compoundDatabaseService.delete(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subcollectionPath: subcollectionPath,
      subDocumentId: item.billId!,
    );
  }

  @override
  Future<BillModel> save({required BillModel item, bool? save}) async {
    final rootDocumentId = getRootDocumentId(item.billTypeModel);
    final subcollectionPath = getSubCollectionPath(item.billTypeModel);
    if (item.billId == null) {
      final newBillModel =
          await _createNewBill(bill: item, rootDocumentId: rootDocumentId, subcollectionPath: subcollectionPath);
      return newBillModel;
    } else {
      await compoundDatabaseService.update(
        rootCollectionPath: rootCollectionPath,
        rootDocumentId: rootDocumentId,
        subcollectionPath: subcollectionPath,
        subDocumentId: item.billId!,
        data: item.toJson(),
      );
      return item;
    }
  }

  Future<BillModel> _createNewBill(
      {required BillModel bill, required String rootDocumentId, required String subcollectionPath}) async {
    final newBillNumber = await getNextNumber(rootCollectionPath, bill.billTypeModel.billTypeLabel!);

    final newBillJson = bill.copyWith(billDetails: bill.billDetails.copyWith(billNumber: newBillNumber)).toJson();

    final data = await compoundDatabaseService.add(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subcollectionPath: subcollectionPath,
      data: newBillJson,
    );

    return BillModel.fromJson(data);
  }

  @override
  Future<int> countDocuments({required BillTypeModel itemTypeModel, CountQueryFilter? countQueryFilter}) async {
    final rootDocumentId = getRootDocumentId(itemTypeModel);
    final subCollectionPath = getSubCollectionPath(itemTypeModel);

    final count = await compoundDatabaseService.countDocuments(
      rootCollectionPath: rootCollectionPath,
      rootDocumentId: rootDocumentId,
      subcollectionPath: subCollectionPath,
      countQueryFilter: countQueryFilter,
    );

    return count;
  }
}
