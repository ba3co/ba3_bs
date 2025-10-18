import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../core/print_job.dart';
import '../escpos/escpos_generator.dart';


abstract class BaseTemplate {
  Future<List<int>> build(EscposGenerator g, PrintJob job);


  PaperSize get paperSize;
}