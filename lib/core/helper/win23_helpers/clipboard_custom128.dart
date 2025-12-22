import 'dart:ffi';
import 'dart:typed_data';
import 'package:flutter/material.dart';

import 'win32_clipboard_helpers.dart';

void setClipboardCustom128(Uint8List data) {
  if (openClipboard(0) == 0) throw Exception('Cannot open clipboard');

  try {
    final hGlobal = globalAlloc(GMEM_MOVEABLE, data.length);
    if (hGlobal == 0) throw Exception('GlobalAlloc failed');

    final ptr = globalLock(hGlobal);
    if (ptr == nullptr) throw Exception('GlobalLock failed');

    final bytePtr = ptr.cast<Uint8>();
    for (var i = 0; i < data.length; i++) {
      bytePtr[i] = data[i];
    }

    globalUnlock(hGlobal);

    if (setClipboardData(CF_CUSTOM_128, hGlobal) == 0) {
      throw Exception('SetClipboardData failed');
    }

    debugPrint('Custom clipboard format 128 added successfully.');
  } finally {
    closeClipboard();
  }
}
