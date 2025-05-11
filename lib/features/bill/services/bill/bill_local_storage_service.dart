import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../patterns/data/models/bill_type_model.dart';
import '../../data/models/bill_model.dart';

class BillLocalStorageService {
  static const String _nestedBoxName = 'nestedBillsBox';

  Future<bool> hasData() async {

    final box = await Hive.openBox<List>(_nestedBoxName);
    log('BillLocalStorageService hasData ${box.isNotEmpty}');
    return box.isNotEmpty;
  }

  Future<void> saveNestedBills(Map<BillTypeModel, List<BillModel>> nestedBills) async {
    final box = Hive.isBoxOpen(_nestedBoxName) ? Hive.box<List>(_nestedBoxName) : await Hive.openBox<List>(_nestedBoxName);

    for (var entry in nestedBills.entries) {
      await box.put(entry.key.billTypeId, entry.value);
    }
  }

  Future<Map<String, List<BillModel>>> getNestedBills() async {
    final box = Hive.isBoxOpen(_nestedBoxName) ? Hive.box<List>(_nestedBoxName) : await Hive.openBox<List>(_nestedBoxName);

    final Map<String, List<BillModel>> result = {};

    box.toMap().forEach((key, value) {
      result[key.toString()] = value.cast<BillModel>(); // ✅ التحويل الآمن
    });

    return result;
  }

  Future<void> clearAllBills() async {
    final box = await Hive.openBox<List>(_nestedBoxName);
    await box.clear();
  }

  Future<void> saveSingleBill(BillModel bill) async {
    final billTypeId = bill.billTypeModel.billTypeId!;
    final box = await Hive.openBox<List>(BillLocalStorageService._nestedBoxName);

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