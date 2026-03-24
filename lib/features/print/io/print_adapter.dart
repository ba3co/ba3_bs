import '../core/print_result.dart';


abstract class PrintAdapter {
  Future<PrintResult> send(List<int> bytes, {required String printerName});
}