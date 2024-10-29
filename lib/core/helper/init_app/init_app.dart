import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import '../../../firebase_options.dart';
import '../../bindings/model_deserialization_registry.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeWindowSettings();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  setupModelDeserializationRegistry();
}

Future<void> initializeWindowSettings() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 600),
    minimumSize: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    windowButtonVisibility: true,
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}
