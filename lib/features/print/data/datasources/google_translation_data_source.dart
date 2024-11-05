// google_translation_data_source.dart

import 'dart:convert';

import 'package:ba3_bs/core/classes/datasources/translation_data_source_base.dart';

import '../../../../core/classes/datasources/http_client_base.dart';

class GoogleTranslationDataSource implements TranslationDataSourceBase {
  final String baseUrl;
  final String apiKey;
  final HttpClientBase httpClient;

  GoogleTranslationDataSource({required this.baseUrl, required this.apiKey, required this.httpClient});

  @override
  Future<String> getTranslation(String text) async {
    return await translateText(text, 'ar', 'en');
  }

  Future<String> translateText(String text, String fromLang, String toLang) async {
    final String url = '$baseUrl?key=$apiKey';

    try {
      final response = await httpClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'q': text, 'source': fromLang, 'target': toLang, 'format': 'text'}),
      );

      return response['data']['translations'][0]['translatedText'];
    } catch (e) {
      throw Exception('Failed to translate text: $e');
    }
  }
}
