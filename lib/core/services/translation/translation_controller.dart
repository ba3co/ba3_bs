import 'dart:ui';

import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:get/get.dart';

import '../local_database/interfaces/i_local_database_service.dart';

class TranslationController extends GetxController {
  final ILocalDatabaseService<String> appLocalLangService;

  TranslationController(this.appLocalLangService);

  String get localLangCode => appLocalLangService.fetchById(AppConstants.appLocalLangBox) ?? AppConstants.defaultLangCode;

  Future<void> changeLang(String langCode) async {
    await appLocalLangService.insert(AppConstants.appLocalLangBox, langCode);
    Get.updateLocale(Locale(langCode));
  }
}
