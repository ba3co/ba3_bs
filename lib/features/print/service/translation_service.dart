
import '../../../core/services/translation/implementations/translation_repo.dart';

class TranslationService {
  final TranslationRepository repo;
  const TranslationService(this.repo);


  Future<String> safeTranslate(String text) async {
    try {
      return await repo.translateText(text);
    } catch (_) {
      return text; // fallback silently
    }
  }
}