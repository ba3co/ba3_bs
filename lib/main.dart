import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

import 'apps/app.dart';
import 'apps/blocked_app.dart';
import 'core/helper/init_app/app_initializer.dart';
import 'core/services/firebase/implementations/services/remote_config_service.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppServices();

  Map<String, dynamic> data = {};
  if (args.length >= 3) {
    final payload = args[2];
    log('✅ Payload JSON: $payload');
    data = jsonDecode(payload);
  }
  log('data: ${data['screenName'] ?? ''}', name: 'Main');
  final isAppEnabled = RemoteConfigService.isAppEnabled;
  log('isAppEnabled: $isAppEnabled', name: 'RemoteConfigService');
  runApp(isAppEnabled ? const MyApp() : const BlockedApp());
}