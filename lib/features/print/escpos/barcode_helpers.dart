import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class Barcodes {
  static Barcode forLabel(String? value) {
    if (value == null || value.isEmpty) {
      throw ArgumentError('Barcode value cannot be null or empty');
    }
    // Convert the string to a list of code units (List<int>)
    return Barcode.code128(value.codeUnits);
  }
}