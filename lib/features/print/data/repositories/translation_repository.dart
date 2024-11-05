import 'package:flutter/cupertino.dart';

import '../../../../core/classes/datasources/translation_data_source_base.dart';

class TranslationRepository {
  final TranslationDataSourceBase _dataSource;

  TranslationRepository(this._dataSource);

  Future<String> translateText(String text) async {
    if (_isArabic(text)) {
      try {
        return await _dataSource.getTranslation(text);
      } catch (e) {
        debugPrint('Translation error: $e');
        return text; // Return original text as a fallback in case of translation failure
      }
    } else {
      return text;
    }
  }

  bool _isArabic(String text) {
    return text.runes.any((c) => c >= 0x0600 && c <= 0x06FF);
  }
}
