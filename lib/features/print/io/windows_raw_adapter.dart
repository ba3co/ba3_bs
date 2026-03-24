// lib/features/print/io/windows_raw_adapter.dart

import 'dart:developer';
import 'dart:typed_data';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart'; // مهم: نستخدم calloc/toNativeUtf16 من هون (بدون prefix)
import 'package:win32/win32.dart' as win32;

import '../core/print_result.dart';
import 'print_adapter.dart';

class WindowsRawAdapter implements PrintAdapter {
  @override
  Future<PrintResult> send(List<int> ticket, {required String printerName}) async {
    try {
      final data = Uint8List.fromList(ticket);

      // امتدادات toNativeUtf16 من package:ffi/ffi.dart
      final printerNamePtr = printerName.toNativeUtf16();

      // OpenPrinter يتوقع LPHANDLE => Pointer<IntPtr>
      final pHandle = calloc<ffi.IntPtr>();
      final pDefaults = calloc<win32.PRINTER_DEFAULTS>();
      pDefaults.ref
        ..pDatatype = win32.TEXT('RAW')
        ..pDevMode = ffi.nullptr
        ..DesiredAccess = win32.PRINTER_ACCESS_USE;

      final opened = win32.OpenPrinter(printerNamePtr, pHandle, pDefaults);
      if (opened == 0) {
        final err = win32.GetLastError();
        _freeAll(
          printerNamePtr: printerNamePtr,
          pHandle: pHandle,
          pDefaults: pDefaults,
        );
        return PrintResult(false, 'OpenPrinter failed ($err)');
      }

      final docInfo = calloc<win32.DOC_INFO_1>();
      docInfo.ref
        ..pDocName = win32.TEXT('ESC/POS from Flutter')
        ..pOutputFile = ffi.nullptr
        ..pDatatype = win32.TEXT('RAW');

      final docId = win32.StartDocPrinter(pHandle.value, 1, docInfo);
      if (docId <= 0) {
        final err = win32.GetLastError();
        win32.ClosePrinter(pHandle.value);
        _freeAll(
          printerNamePtr: printerNamePtr,
          pHandle: pHandle,
          pDefaults: pDefaults,
          docInfo: docInfo,
        );
        return PrintResult(false, 'StartDocPrinter failed ($err)');
      }

      if (win32.StartPagePrinter(pHandle.value) == 0) {
        final err = win32.GetLastError();
        win32.EndDocPrinter(pHandle.value);
        win32.ClosePrinter(pHandle.value);
        _freeAll(
          printerNamePtr: printerNamePtr,
          pHandle: pHandle,
          pDefaults: pDefaults,
          docInfo: docInfo,
        );
        return PrintResult(false, 'StartPagePrinter failed ($err)');
      }

      final dataPtr = calloc<ffi.Uint8>(data.length);
      dataPtr.asTypedList(data.length).setAll(0, data);
      final written = calloc<ffi.Uint32>();

      final ok = win32.WritePrinter(pHandle.value, dataPtr, data.length, written);
      if (ok == 0) {
        final err = win32.GetLastError();
        log('WritePrinter failed ($err)');
      } else {
        log('Wrote ${written.value} bytes to printer');
      }

      win32.EndPagePrinter(pHandle.value);
      win32.EndDocPrinter(pHandle.value);
      win32.ClosePrinter(pHandle.value);

      _freeAll(
        printerNamePtr: printerNamePtr,
        pHandle: pHandle,
        pDefaults: pDefaults,
        docInfo: docInfo,
        dataPtr: dataPtr,
        written: written,
      );

      return const PrintResult(true);
    } catch (e) {
      return PrintResult(false, 'WindowsRaw error: $e');
    }
  }

  void _freeAll({
    ffi.Pointer<Utf16>? printerNamePtr,
    ffi.Pointer<ffi.IntPtr>? pHandle,
    ffi.Pointer<win32.PRINTER_DEFAULTS>? pDefaults,
    ffi.Pointer<win32.DOC_INFO_1>? docInfo,
    ffi.Pointer<ffi.Uint8>? dataPtr,
    ffi.Pointer<ffi.Uint32>? written,
  }) {
    if (printerNamePtr != null) calloc.free(printerNamePtr);
    if (pHandle != null) calloc.free(pHandle);
    if (pDefaults != null) calloc.free(pDefaults);
    if (docInfo != null) calloc.free(docInfo);
    if (dataPtr != null) calloc.free(dataPtr);
    if (written != null) calloc.free(written);
  }
}