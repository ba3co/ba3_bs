/*
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:ba3_bs/core/constants/printer_constants.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart' as win32;
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';
import 'dart:ffi' as ffi;


class CrossPlatformPrinter {
  CrossPlatformPrinter();

  Future<void> printBillBytes({
    required List<int> escposBytes,
    required String printerName,
  }) async {
    if (Platform.isWindows) {
      await _sendRawWindows(escposBytes, printerName);
    } else if (Platform.isMacOS) {
      await _sendRawMac(escposBytes, printerName);
    } else {
      throw UnsupportedError('Only Windows and macOS are supported in this path.');
    }
  }

  /// Windows: RAW via Win32
  Future<void> _sendRawWindows(List<int> bytes, String printerName) async {
    try {
      final namePtr = printerName.toNativeUtf16();
      final pHandle = calloc<IntPtr>();
      final pDefaults = calloc<win32.PRINTER_DEFAULTS>();
      pDefaults.ref
        ..pDatatype = win32.TEXT('RAW')
        ..pDevMode = nullptr
        ..DesiredAccess = win32.PRINTER_ACCESS_USE; // 0x00000008

      final opened = win32.OpenPrinter(namePtr, pHandle, pDefaults);
      if (opened == 0) {
        log('OpenPrinter failed: ${win32.GetLastError()}');
        calloc.free(namePtr);
        calloc
          ..free(pHandle)
          ..free(pDefaults);
        return;
      }

      final docInfo = calloc<win32.DOC_INFO_1>();
      docInfo.ref
        ..pDocName = win32.TEXT('ESC/POS from Flutter')
        ..pOutputFile = nullptr
        ..pDatatype = win32.TEXT('RAW');

      final docId = win32.StartDocPrinter(pHandle.value, 1, docInfo);
      if (docId <= 0) {
        log('StartDocPrinter failed: ${win32.GetLastError()}');
        win32.EndDocPrinter(pHandle.value);
        win32.ClosePrinter(pHandle.value);
        calloc.free(namePtr);
        calloc
          ..free(pHandle)
          ..free(pDefaults)
          ..free(docInfo);
        return;
      }

      if (win32.StartPagePrinter(pHandle.value) == 0) {
        log('StartPagePrinter failed: ${win32.GetLastError()}');
        win32.EndDocPrinter(pHandle.value);
        win32.ClosePrinter(pHandle.value);
        calloc.free(namePtr);
        calloc
          ..free(pHandle)
          ..free(pDefaults)
          ..free(docInfo);
        return;
      }

      final data = Uint8List.fromList(bytes);
      final dataPtr = calloc<Uint8>(data.length);
      dataPtr.asTypedList(data.length).setAll(0, data);
      final written = calloc<Uint32>();

      final ok = win32.WritePrinter(pHandle.value, dataPtr, data.length, written);
      if (ok == 0) {
        log('WritePrinter failed: ${win32.GetLastError()}');
      } else {
        log('Wrote ${written.value} bytes');
      }

      win32.EndPagePrinter(pHandle.value);
      win32.EndDocPrinter(pHandle.value);
      win32.ClosePrinter(pHandle.value);

      calloc
        ..free(namePtr)
        ..free(pHandle)
        ..free(pDefaults)
        ..free(docInfo)
        ..free(dataPtr)
        ..free(written);
    } catch (e) {
      log('Exception Windows RAW: $e');
    }
  }

  /// macOS: CUPS via `lp -o raw` (نكتب ملف مؤقت ونرسله)
  Future<void> _sendRawMac(List<int> bytes, String printerName) async {
    try {
      // اكتب الملف المؤقّت
      final tmp = await File('${Directory.systemTemp.path}/escpos_${DateTime.now().millisecondsSinceEpoch}.bin').create();
      await tmp.writeAsBytes(bytes, flush: true);

      // lp -d <printer> -o raw <file>
      final result = await Process.run('lp', ['-d', printerName, '-o', 'raw', tmp.path]);
      log('lp stdout: ${result.stdout}');
      log('lp stderr: ${result.stderr}');
      if (result.exitCode != 0) {
        throw Exception('lp failed with code ${result.exitCode}');
      }

      // حذف الملف بعد الإرسال (اختياري)
      try { await tmp.delete(); } catch (_) {}
    } catch (e) {
      log('Exception macOS RAW (lp): $e');
      rethrow;
    }
  }
}
class PrinterConstants {
  static const printerNameWindows = 'E-PoS printer driver';
  static const printerNameMac = 'EPSON_TM_T20II';
  static String get printerName => Platform.isWindows ? printerNameWindows : printerNameMac;
}*/