import 'dart:convert';
import 'dart:developer';

import 'package:ba3_bs/features/bill/ui/screens/add_bill_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../features/patterns/data/models/bill_type_model.dart';
import '../firebase_options.dart';

bool isMultiWindowMode(List<String> args) => args.isNotEmpty && args.firstOrNull == 'multi_window';

Future<void> runMultiWindow(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for multi-window mode
  if (Firebase.apps.isEmpty || Firebase.apps.every((app) => app.name != 'AddBillApp')) {
    await Firebase.initializeApp(
      name: 'AddBillApp',
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Parse window arguments
  final windowId = int.tryParse(args[1]) ?? 0;
  final parsedArgs = parseWindowArguments(args[2]);

  log('Window ID: $windowId, Arguments: $parsedArgs');

  // Extract arguments
  final billTypeModel = BillTypeModel.fromJson(parsedArgs['billTypeModel']);
  final fromBillDetails = parsedArgs['fromBillDetails'] ?? false;
  final fromBillById = parsedArgs['fromBillById'] ?? false;

  log('Launching multi-window with billTypeModel: ${billTypeModel.toJson()}');

  runApp(
    AddBillScreen(
      billTypeModel: billTypeModel,
      fromBillDetails: fromBillDetails,
      fromBillById: fromBillById,
      firebaseApp: Firebase.app('AddBillApp'),
    ),
  );
}

Map<String, dynamic> parseWindowArguments(String jsonArgs) {
  try {
    return jsonDecode(jsonArgs) as Map<String, dynamic>;
  } catch (e) {
    log('Failed to parse arguments: $e');
    return const {};
  }
}
