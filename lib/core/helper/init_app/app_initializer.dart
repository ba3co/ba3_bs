import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;


import '../../../firebase_options.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS)) {
    await initializeWindowSettings();

  } else {

  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> initializeWindowSettings() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 600),
    minimumSize: Size(1000, 600),
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
