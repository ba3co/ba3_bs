import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../data/models/bond_model.dart';

class BondLocalStorageService {
  static const String _nestedBoxName = 'nestedBondsBox';

  Future<void> saveNestedBonds(Map<BondType, List<BondModel>> nestedBonds) async {
    log('BondLocalStorageService');
    nestedBonds.forEach((k, v) => log('bond Type: ${k.label} has ${v.length} bonds', name: 'saveNestedBonds'));

    final box = Hive.isBoxOpen(_nestedBoxName)
        ? Hive.box<List>(_nestedBoxName)
        : await Hive.openBox<List>(_nestedBoxName);

    for (var entry in nestedBonds.entries) {
      await box.put(entry.key.typeGuide, entry.value);
    }
  }

  Future<Map<String, List<BondModel>>> getNestedBonds() async {
    final box = Hive.isBoxOpen(_nestedBoxName)
        ? Hive.box<List>(_nestedBoxName)
        : await Hive.openBox<List>(_nestedBoxName);

    return box.toMap().map(
          (key, value) => MapEntry(
        key.toString(),
        value.cast<BondModel>(),
      ),
    );
  }

  Future<void> clearAllBonds() async {
    final box = Hive.isBoxOpen(_nestedBoxName)
        ? Hive.box<List>(_nestedBoxName)
        : await Hive.openBox<List>(_nestedBoxName);
    await box.clear();
  }

  Future<void> saveSingleBond(BondModel bond) async {
    final bondTypeId = bond.payTypeGuid!;
    final box = Hive.isBoxOpen(_nestedBoxName)
        ? Hive.box<List>(_nestedBoxName)
        : await Hive.openBox<List>(_nestedBoxName);

    final currentList = List<BondModel>.from(box.get(bondTypeId, defaultValue: []) ?? []);
    final index = currentList.indexWhere((b) => b.payGuid == bond.payGuid);

    if (index != -1) {
      currentList[index] = bond; // Update
    } else {
      currentList.add(bond); // Add
    }

    await box.put(bondTypeId, currentList);
  }
  Future<bool> hasData() async {
    final box = await Hive.openBox<List>(_nestedBoxName);
    return box.isNotEmpty;
  }
}