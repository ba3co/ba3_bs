import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_constants.dart';
import '../../../../core/services/firebase/implementations/services/firestore_sequential_numbers.dart';
import '../../../patterns/data/models/bill_type_model.dart';

class BillsCountsService with FirestoreSequentialNumbers {
  static const _allBillsCountsByTypeStorageKey = 'allBillsCountsByType';
  static const _allBillsLastNumbersStorageKey = 'allBillsLastNumbersByType';

  // Declare a late variable to hold SharedPreferences instance.
  late final SharedPreferences _prefs;

  // Private constructor to accept SharedPreferences instance
  BillsCountsService._(this._prefs);

  // Factory method to initialize the service and get the SharedPreferences instance.
  static Future<BillsCountsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return BillsCountsService._(prefs);
  }

  // ------------- Last Numbers Logic (Sequential numbers) -------------

  Future<int> getBillsLastNumberByType(BillTypeModel billTypeModel) async {
    if (await hasInternetConnection()) {
      final lastNumber = await _fetchLastNumberFromServer(billTypeModel);
      await _saveSingleLastNumberLocally(billTypeModel.billTypeLabel!, lastNumber);
      return lastNumber;
    } else {
      final localLastNumbers = await _loadLastNumbersFromLocal();
      return localLastNumbers[billTypeModel.billTypeLabel!] ?? 0;
    }
  }

  Future<int> _fetchLastNumberFromServer(BillTypeModel billTypeModel) async {
    return await getLastNumber(
      category: ApiConstants.bills,
      entityType: billTypeModel.billTypeLabel!,
    );
  }

  Future<void> _saveSingleLastNumberLocally(String billTypeLabel, int lastNumber) async {
    final currentLastNumbers = await _loadLastNumbersFromLocal();
    currentLastNumbers[billTypeLabel] = lastNumber;
    final jsonString = jsonEncode(currentLastNumbers);
    await _prefs.setString(_allBillsLastNumbersStorageKey, jsonString);
  }

  Future<Map<String, int>> _loadLastNumbersFromLocal() async {
    final jsonString = _prefs.getString(_allBillsLastNumbersStorageKey);
    if (jsonString != null) {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }

  // ------------- Counts Logic (Total number of bills) -------------

  Future<void> saveAllBillsCountsLocally(Map<String, int> countsByLabel) async {
    final jsonString = jsonEncode(countsByLabel);
    await _prefs.setString(_allBillsCountsByTypeStorageKey, jsonString);
  }

  Future<Map<String, int>> loadAllBillsCountsLocally() async {
    final jsonString = _prefs.getString(_allBillsCountsByTypeStorageKey);
    if (jsonString != null) {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value as int));
    }
    return {};
  }
}

Future<bool> hasInternetConnection() async {
  try {
    final connectivityResults = await Connectivity().checkConnectivity();
    return connectivityResults.isNotEmpty && connectivityResults.any((result) => result != ConnectivityResult.none);
  } catch (e) {
    log('Error checking connectivity: $e', name: 'CompoundFireStoreService');
    return false;
  }
}