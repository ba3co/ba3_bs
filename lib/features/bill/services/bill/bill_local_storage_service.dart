import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';

class BillLocalStorageService {
  static const String _nestedBoxName = 'nestedBillsBox';

  Future<bool> hasData() async {
    final box = await Hive.openBox<List<BillModel>>(_nestedBoxName);
    return box.isNotEmpty;
  }

  Future<void> saveNestedBills(Map<BillTypeModel, List<BillModel>> nestedBills) async {
    log('BillLocalStorageService');
    nestedBills.forEach((k, v) => log('bill Type: ${k.billTypeLabel} has ${v.length} bills', name: 'saveNestedBills'));

    final box = await Hive.openBox<List<BillModel>>(_nestedBoxName);
    for (var entry in nestedBills.entries) {
      await box.put(entry.key.billTypeId, entry.value);
    }
  }

  Future<Map<String, List<BillModel>>> getNestedBills() async {
    final box = await Hive.openBox<List<BillModel>>(_nestedBoxName);
    return box.toMap().map((key, value) => MapEntry(key.toString(), List<BillModel>.from(value)));
  }

  Future<void> clearAllBills() async {
    final box = await Hive.openBox<List<BillModel>>(_nestedBoxName);
    await box.clear();
  }

  Future<void> saveSingleBill(BillModel bill) async {
    final billTypeId = bill.billTypeModel.billTypeId!;
    final box = await Hive.openBox<List<BillModel>>(BillLocalStorageService._nestedBoxName);

    final currentList = List<BillModel>.from(box.get(billTypeId, defaultValue: []) ?? []);

    final index = currentList.indexWhere((b) => b.billId == bill.billId);

    if (index != -1) {
      currentList[index] = bill; // Update existing
    } else {
      currentList.add(bill); // Add new
    }

    await box.put(billTypeId, currentList);
  }
}
