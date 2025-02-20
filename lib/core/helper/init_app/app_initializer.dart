
import 'package:ba3_bs/core/helper/extensions/hive_extensions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:window_manager/window_manager.dart';

import '../../../firebase_options.dart';
import '../../constants/app_constants.dart';
import '../../services/local_database/implementations/services/hive_database_service.dart';
import '../../services/translation/translation_controller.dart';

Future<void> initializeApp() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure window settings for desktop platforms
    await initializeWindowSettings();


  // Initialize the default Firebase app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Hive
  await Hive.initializeApp();

  await _initializeAppLocalLangService(boxName: AppConstants.appLocalLangBox);
}

Future<void> _initializeAppLocalLangService({required String boxName}) async {
  final Box<String> box = await Hive.openBox<String>(boxName);

  final HiveDatabaseService<String> hiveLocalLangService = HiveDatabaseService(box);

  Get.put(TranslationController(hiveLocalLangService));
}

Future<void> initializeWindowSettings() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    size: Size(1000, 800),
    minimumSize: Size(1000, 800),
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