import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/bindings/bindings.dart';
import 'core/constants/app_strings.dart';
import 'core/helper/extensions/getx_controller_extensions.dart';
import 'core/helper/init_app/app_initializer.dart';
import 'core/router/app_router.dart';
import 'core/services/translation/app_translations.dart';
import 'core/services/translation/translation_controller.dart';
import 'core/styling/app_themes.dart';
import 'core/widgets/app_scroll_behavior.dart';

void main() async {
  await initializeAppServices();

  runApp(MyApp());
}


// PARENT1727449068863000
//https://firebasestorage.googleapis.com/v0/b/vision-educational-de149.appspot.com/o/images%2Fcontracts%2F1741592523585.png?alt=media&token=2b2eaf51-665d-484c-8684-a3c39a30dcd6
//https://firebasestorage.googleapis.com/v0/b/vision-educational-de149.appspot.com/o/images%2Fcontracts%2F1741592581604.png?alt=media&token=38ea28e2-a739-45e7-9aa9-ac5e8bc0681a
//https://firebasestorage.googleapis.com/v0/b/vision-educational-de149.appspot.com/o/images%2Fcontracts%2F1741592618602.png?alt=media&token=d3a3787b-92a9-4713-8c64-68ea890cfaca

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TranslationController translationController = read<TranslationController>();

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
        title: AppStrings.appTitle.tr,
        theme: AppThemes.defaultTheme,
        getPages: appRouter,
      ),
    );
  }
}