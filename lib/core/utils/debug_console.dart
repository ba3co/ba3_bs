import 'dart:developer';

import 'package:flutter/foundation.dart';

class DebugConsole {
  DebugConsole._();

  /// Print Errors
  static void e(String text) {
    if (kDebugMode) {
      log('\x1B[31m${'                  ================'}\x1B[0m \n \x1B[31m${'--------->   ❌  $text'}\x1B[0m \n\x1B[31m${'                  ================'}\x1B[0m');
    }
  }

  /// Print Warnings
  static void w(String text) {
    if (kDebugMode) {
      log('\x1B[35m${'                  ================'}\x1B[0m \n \x1B[35m${'--------->   🚫  $text'}\x1B[0m \n\x1B[35m${'                  ================'}\x1B[0m');
    }
  }

  /// Print Information
  static void i(String text) {
    if (kDebugMode) {
      log('\x1B[37m${'                  ================'}\x1B[0m \n \x1B[37m${'--------->  ℹ️   $text'}\x1B[0m \n\x1B[37m${'                  ================'}\x1B[0m');
    }
  }

  /// Print Success
  static void s(String text) {
    if (kDebugMode) {
      log('\x1B[32m${'                  ================'}\x1B[0m \n \x1B[32m${'--------->   👌  $text'}\x1B[0m \n\x1B[32m${'                  ================'}\x1B[0m');
    }
  }
}
