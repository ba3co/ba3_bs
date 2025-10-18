import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';


enum PaperKind { mm58, mm80, label }


enum PlatformKind { windows, macos }


class PrinterDevice {
  final String name; // CUPS/Spooler name e.g., POS58, POS80, DYMO
  final PaperKind paperKind; // 58/80/label
  final PlatformKind platform; // windows | macos
  final CapabilityProfile? profile; // optional custom profile


  const PrinterDevice({
    required this.name,
    required this.paperKind,
    required this.platform,
    this.profile,
  });
}