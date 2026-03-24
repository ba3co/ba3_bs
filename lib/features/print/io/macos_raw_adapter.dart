import 'dart:convert';
import 'dart:io';
import '../core/print_result.dart';
import 'print_adapter.dart';


class MacosRawAdapter implements PrintAdapter {
  @override
  Future<PrintResult> send(List<int> ticket, {required String printerName}) async {
    try {
// Try lp -d <printer> -o raw
      var p = await Process.start('/usr/bin/lp', ['-d', printerName, '-o', 'raw']);
      p.stdin.add(ticket);
      await p.stdin.close();
      var code = await p.exitCode;
      if (code == 0) return const PrintResult(true);


// Fallback: lpr -P <printer> -l
      p = await Process.start('/usr/bin/lpr', ['-P', printerName, '-l']);
      p.stdin.add(ticket);
      await p.stdin.close();
      code = await p.exitCode;
      if (code == 0) return const PrintResult(true);


      final out = await p.stdout.transform(const Utf8Decoder()).join();
      final err = await p.stderr.transform(const Utf8Decoder()).join();
      return PrintResult(false, 'macOS print failed: $out $err');
    } catch (e) {
      return PrintResult(false, 'macOS adapter error: $e');
    }
  }
}