
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../../../core/constants/app_assets.dart';


/// مساعد طباعة اللوغو بشكل آمن وقابل لإعادة الاستخدام.
class LogoHelper{
  static Future<List<int>> generateLogo(PaperSize paperSize) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);

    final int logoWidthPx = paperSize == PaperSize.mm58 ? 200 : 300;
    try {
      // 1) حمّل الصورة وفكّ ترميزها
      final data = await rootBundle.load(AppAssets.ba3Logo);
      final img.Image? decoded =
      img.decodeImage(Uint8List.fromList(data.buffer.asUint8List()));
      if (decoded == null) {
        debugPrint('Logo decode failed');
        return const <int>[];
      }

      // 2) احسب أقصى عرض بالنقاط بناءً على مقاس الورق (203dpi شائع)
      // mm80 ≈ 576dots, mm58 ≈ 384dots
      final int maxDots =
      (paperSize == PaperSize.mm80) ? 576 : 384;

      // استعمل قيمة مخصّصة لو موجودة، لكن لا تتجاوز maxDots
      final int targetWidth = (logoWidthPx)
          .clamp(64, maxDots); // حد أدنى 64 حتى نتجنّب مشاكل صغيرة

      // 3) غيّر الحجم مع الحفاظ على النسبة
      final img.Image resized = img.copyResize(
        decoded,
        width: targetWidth,
        interpolation: img.Interpolation.average,
        // preserveAspectRatio: true,
      );

      // 4) بعض الرولات تتطلّب عرضًا مضاعفًا لـ 8
      final int w8 = resized.width - (resized.width % 8);
      final img.Image ready =
      (w8 == resized.width) ? resized : img.copyResize(resized, width: w8);

      // 5) جرّب raster أولاً (أجود). لو فشل لأي سبب، fallback إلى image()
      try {
        final bytes = generator.imageRaster(
          ready,
          align: PosAlign.center,
        );
        return List<int>.from(bytes, growable: true);
      } catch (e) {
        debugPrint('imageRaster failed, fallback to image(): $e');
        final bytes = generator.image(
          ready,
          align: PosAlign.center,
        );
        return List<int>.from(bytes, growable: true);
      }
    } catch (e) {
      debugPrint('Logo generation error: $e');
      // لا توقف الطباعة بسبب الشعار
      return const <int>[];
    }
  }

}