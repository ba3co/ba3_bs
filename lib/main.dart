import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'apps/app.dart';
import 'apps/blocked_app.dart';
import 'core/helper/init_app/app_initializer.dart';
import 'core/services/firebase/implementations/services/remote_config_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeAppServices();
  final isAppEnabled = RemoteConfigService.isAppEnabled;
  log('isAppEnabled: $isAppEnabled', name: 'RemoteConfigService');
  runApp(isAppEnabled ? const MyApp() : const BlockedApp());
}

Future<void> transferData() async {
  debugPrint("start import");
  // تهيئة Firebase
  await Firebase.initializeApp();

  // الاتصال بالـ production (الافتراضي)
  final firestoreReal = FirebaseFirestore.instance;

  // الاتصال بالـ test instance
  final firestoreTest = FirebaseFirestore.instanceFor(
    app: Firebase.app(),
    databaseId: 'test', // غيرها إذا عندك اسم تاني
  );

  // جلب البيانات من كولكشن معين (مثلاً orders)
  final querySnapshot =
  await firestoreReal.collection("003345fb-1dc0-4a69-af2a-ee1c48f2f183").get();




  // نسخ البيانات للـ test
  for (var doc in querySnapshot.docs) {
    await firestoreTest
        .collection("003345fb-1dc0-4a69-af2a-ee1c48f2f183")
        .doc(doc.id)
        .set(doc.data());
  }

  debugPrint("✅ تم نقل البيانات من real إلى test");
}
