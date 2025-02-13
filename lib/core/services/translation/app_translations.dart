import 'package:ba3_bs/core/services/translation/ur_translations.dart';
import 'package:get/get.dart';
import 'ar_translations.dart';
import 'en_translations.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
   'ar_AR': arAR,
   'en_US': enUS,
   'ur_PK': urPK,
  };
}
