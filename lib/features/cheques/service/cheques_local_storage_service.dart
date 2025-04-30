import 'dart:developer';

import 'package:hive/hive.dart';

import '../../../../core/helper/enums/enums.dart';
import '../data/models/cheques_model.dart';

class ChequesLocalStorageService {
  static const String _nestedBoxName = 'nestedChequesBox';

  Future<bool> hasData() async {
    final box = await Hive.openBox<List<ChequesModel>>(_nestedBoxName);
    return box.isNotEmpty;
  }

  Future<void> saveNestedCheques(Map<ChequesType, List<ChequesModel>> nestedChequess) async {
    log('ChequesLocalStorageService');
    nestedChequess.forEach((k, v) => log('cheques Type: ${k.label} has ${v.length} cheques', name: 'saveNestedCheques'));

    final box = await Hive.openBox<List<ChequesModel>>(_nestedBoxName);
    for (var entry in nestedChequess.entries) {
      await box.put(entry.key.typeGuide, entry.value);
    }
  }

  Future<Map<String, List<ChequesModel>>> getNestedCheques() async {
    final box = await Hive.openBox<List<ChequesModel>>(_nestedBoxName);
    return box.toMap().map((key, value) => MapEntry(key.toString(), List<ChequesModel>.from(value)));
  }

  Future<void> clearAllChequess() async {
    final box = await Hive.openBox<List<ChequesModel>>(_nestedBoxName);
    await box.clear();
  }

  Future<void> saveSingleCheques(ChequesModel cheques) async {
    final chequesTypeId = cheques.chequesPayGuid!;
    final box = await Hive.openBox<List<ChequesModel>>(ChequesLocalStorageService._nestedBoxName);

    final currentList = List<ChequesModel>.from(box.get(chequesTypeId, defaultValue: []) ?? []);

    final index = currentList.indexWhere((b) => b.chequesGuid == cheques.chequesGuid);

    if (index != -1) {
      currentList[index] = cheques; // Update existing
    } else {
      currentList.add(cheques); // Add new
    }

    await box.put(chequesTypeId, currentList);
  }
}