// lib/features/print/escpos/escpos_generator.dart

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;

class EscposGenerator {
  final PaperSize paperSize;
  final CapabilityProfile profile;
  late final Generator gen;

  EscposGenerator(this.paperSize, this.profile) {
    gen = Generator(paperSize, profile);
  }

  List<int> reset() => gen.reset();
  List<int> cut() => gen.cut();
  List<int> empty([int n = 1]) => gen.emptyLines(n);

  // styles يجب أن يكون PosStyles غير-null
  List<int> text(String t, {PosStyles? styles, int linesAfter = 0}) =>
      gen.text(t, styles: styles ?? const PosStyles(), linesAfter: linesAfter);

  List<int> hr([int len = 32]) => gen.text('-' * len);

  List<int> imageRaster(img.Image image, {PosAlign align = PosAlign.center}) =>
      gen.imageRaster(image, align: align);

  List<int> image(img.Image image, {PosAlign align = PosAlign.center}) =>
      gen.image(image, align: align);

  // واجهة متوافقة مع gen.barcode(..) (بدون named: data/fonts)
  List<int> barcode(
      Barcode barcode, {
        required String data,
        int? width,
        int? height,
        BarcodeText textPos = BarcodeText.below,
      }) {
    return gen.barcode(
      barcode,
      // data,
      width: width,
      height: height,
      textPos: textPos,
    );
  }

  List<int> qr(String data, {QRSize size = QRSize.size4}) =>
      gen.qrcode(data, size: size);
}