import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

import 'core/bindings/bindings.dart';
import 'core/constants/app_strings.dart';
import 'core/helper/init_app/app_initializer.dart';
import 'core/router/app_router.dart';
import 'core/styling/app_themes.dart';
import 'core/widgets/app_scroll_behavior.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    // عرض الخطأ على وحدة التحكم
    FlutterError.presentError(details);
    log("FlutterError Error: ${details.exception}");
exit(1);
    // إذا كنت تريد إيقاف تشغيل التطبيق عند الخطأ
    // يمكنك استدعاء exit(1) أو أي إجراء آخر مناسب.
  };
  await initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 852),
      splitScreenMode: true,
      fontSizeResolver: FontSizeResolvers.height,
      child: GetMaterialApp(
        initialBinding: AppBindings(),
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        locale: const Locale("ar"),
        title: AppStrings.appTitle,
        theme: AppThemes.defaultTheme,
        getPages: appRouter,
      ),
    );
  }
}
