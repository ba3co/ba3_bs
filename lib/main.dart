import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/bindings/bindings.dart';
import 'core/constants/app_strings.dart';
import 'core/helper/init_app/app_initializer.dart';
import 'core/router/app_router.dart';
import 'core/services/local_database/interfaces/i_local_database_service.dart';
import 'core/services/translation/app_translations.dart';
import 'core/services/translation/translation_controller.dart';
import 'core/styling/app_themes.dart';
import 'core/widgets/app_scroll_behavior.dart';

void main() async {
  FlutterError.onError = (FlutterErrorDetails details) {
    log("FlutterError Error: ${details.exception}");
    FlutterError.presentError(details);
  };

  final appLocalLangService = await initializeApp();

  runApp(MyApp(appLocalLangService: appLocalLangService));
}

class MyApp extends StatelessWidget {
  final ILocalDatabaseService<String> appLocalLangService;

  const MyApp({super.key, required this.appLocalLangService});

  @override
  Widget build(BuildContext context) {
    final translationController = Get.put(TranslationController(appLocalLangService));

    return ScreenUtilInit(
      designSize: const Size(390, 852),
      splitScreenMode: true,
      fontSizeResolver: FontSizeResolvers.height,
      child: GetMaterialApp(
        initialBinding: AppBindings(),
        debugShowCheckedModeBanner: false,
        scrollBehavior: AppScrollBehavior(),
        locale: Locale(translationController.localLangCode),
        translations: AppTranslations(),
        fallbackLocale: Locale('en', 'US'),
        title: AppStrings.appTitle,
        theme: AppThemes.defaultTheme,
        getPages: appRouter,
      ),
    );
  }
}
