import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../data/models/bond_model.dart';

class BondLocalStorageService {
  static const String _nestedBoxName = 'nestedBondsBox';

  Future<bool> hasData() async {
    final box = await Hive.openBox<List<BondModel>>(_nestedBoxName);
    return box.isNotEmpty;
  }

  Future<void> saveNestedBonds(Map<BondType, List<BondModel>> nestedBonds) async {
    log('BondLocalStorageService');
    nestedBonds.forEach((k, v) => log('bond Type: ${k.label} has ${v.length} bonds', name: 'saveNestedBonds'));

    final box = await Hive.openBox<List<BondModel>>(_nestedBoxName);
    for (var entry in nestedBonds.entries) {
      await box.put(entry.key.typeGuide, entry.value);
    }
  }

  Future<Map<String, List<BondModel>>> getNestedBonds() async {
    final box = await Hive.openBox<List<BondModel>>(_nestedBoxName);
    return box.toMap().map((key, value) => MapEntry(key.toString(), List<BondModel>.from(value)));
  }

  Future<void> clearAllBonds() async {
    final box = await Hive.openBox<List<BondModel>>(_nestedBoxName);
    await box.clear();
  }

  Future<void> saveSingleBond(BondModel bond) async {
    final bondTypeId = bond.payTypeGuid!;
    final box = await Hive.openBox<List<BondModel>>(BondLocalStorageService._nestedBoxName);

    final currentList = List<BondModel>.from(box.get(bondTypeId, defaultValue: []) ?? []);

    final index = currentList.indexWhere((b) => b.payGuid == bond.payGuid);

    if (index != -1) {
      currentList[index] = bond; // Update existing
    } else {
      currentList.add(bond); // Add new
    }

    await box.put(bondTypeId, currentList);
  }
}