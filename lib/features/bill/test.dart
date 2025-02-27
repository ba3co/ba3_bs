// import 'dart:ffi';
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:flutter/material.dart';
// import 'package:ffi/ffi.dart';
// import 'package:win32/win32.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   // تأكد من استبدال "اسم_الطابعة" بالاسم الفعلي للطابعة كما يظهر في إعدادات Windows
//   final String printerName = 'E-PoS printer driver (1)';
//
//   const MyApp({super.key});
//
//   // تحميل CapabilityProfile مرة واحدة فقط
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'مثال طباعة USB على Windows',
//       home: Scaffold(
//         appBar: AppBar(title: const Text('طباعة E-POS على Windows')),
//         body: Center(
//           child: ElevatedButton(
//             onPressed: () async {
//               await printTicket(printerName);
//             },
//             child: const Text('طباعة التذكرة'),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// دالة لإنشاء تذكرة باستخدام esc_pos_utils وإرسالها إلى الطابعة عبر Win32 API.
// Future<void> printTicket(String printerName) async {
//   try {
//     final CapabilityProfile profile = await CapabilityProfile.load();
//
//     // استخدام CapabilityProfile المحمل مسبقًا
//     final Generator generator = Generator(PaperSize.mm80, profile);
//     List<int> ticket = [];
//
//     // إضافة عنوان رئيسي للتذكرة مع تنسيق النص
//     ticket += generator.text(
//       'sWindows',
//       styles: PosStyles(
//         align: PosAlign.center,
//         bold: true,
//         height: PosTextSize.size2,
//         width: PosTextSize.size2,
//       ),
//       linesAfter: 1,
//     );
//
//     // إضافة نص إضافي للتذكرة
//     ticket += generator.text(
//       'dfssd'*200,
//       styles: PosStyles(align: PosAlign.center),
//       linesAfter: 10,
//     );
//
//     // إضافة أمر قطع الورقة
//     // ticket += generator.cut();
//
//     // تحويل بيانات التذكرة إلى Uint8List
//     final Uint8List data = Uint8List.fromList(ticket);
//
//     // تحويل اسم الطابعة إلى مؤشر نصي (Native UTF-16)
//     final printerNamePtr = printerName.toNativeUtf16();
//
//     // تخصيص ذاكرة لمقبض الطابعة
//     final pHandle = calloc<IntPtr>();
//
//     // إعداد هيكل PRINTER_DEFAULTS مع RAW لضمان إرسال البيانات دون معالجة
//     final pDefaults = calloc<PRINTER_DEFAULTS>();
//     pDefaults.ref.pDatatype = TEXT('RAW');
//     pDefaults.ref.pDevMode = nullptr;
//     pDefaults.ref.DesiredAccess = 0x00000008;
//
//     // محاولة فتح الطابعة باستخدام اسم الطابعة
//     final openResult = OpenPrinter(printerNamePtr, pHandle, pDefaults);
//     if (openResult == 0) {
//       print('فشل فتح الطابعة. رمز الخطأ: ${GetLastError()}');
//       calloc.free(printerNamePtr);
//       calloc.free(pHandle);
//       calloc.free(pDefaults);
//       return;
//     }
//
//     // إعداد هيكل DOC_INFO_1 لبدء مستند الطباعة
//     final docInfo = calloc<DOC_INFO_1>();
//     docInfo.ref.pDocName = TEXT('طباعة من Flutter');
//     docInfo.ref.pOutputFile = nullptr;
//     docInfo.ref.pDatatype = TEXT('RAW');
//
//     // بدء مستند الطباعة
//     final docId = StartDocPrinter(pHandle.value, 1, docInfo);
//     if (docId <= 0) {
//       print('فشل بدء مستند الطباعة. رمز الخطأ: ${GetLastError()}');
//       EndDocPrinter(pHandle.value);
//       ClosePrinter(pHandle.value);
//       calloc.free(printerNamePtr);
//       calloc.free(pHandle);
//       calloc.free(pDefaults);
//       calloc.free(docInfo);
//       return;
//     }
//
//     // بدء صفحة الطباعة
//     final startPage = StartPagePrinter(pHandle.value);
//     if (startPage == 0) {
//       print('فشل بدء صفحة الطباعة. رمز الخطأ: ${GetLastError()}');
//       EndDocPrinter(pHandle.value);
//       ClosePrinter(pHandle.value);
//       calloc.free(printerNamePtr);
//       calloc.free(pHandle);
//       calloc.free(pDefaults);
//       calloc.free(docInfo);
//       return;
//     }
//
//     // تخصيص الذاكرة للبيانات التي سيتم إرسالها للطابعة
//     final dataPtr = calloc<Uint8>(data.length);
//     final dataList = dataPtr.asTypedList(data.length);
//     dataList.setAll(0, data);
//
//     // تخصيص متغير لتخزين عدد البايتات المكتوبة
//     final written = calloc<Uint32>();
//
//     // إرسال البيانات للطابعة باستخدام WritePrinter
//     final writeResult = WritePrinter(pHandle.value, dataPtr, data.length, written);
//     if (writeResult == 0) {
//       print('فشل إرسال البيانات للطابعة. رمز الخطأ: ${GetLastError()}');
//     }
//
//     // إنهاء صفحة الطباعة والمستند
//     EndPagePrinter(pHandle.value);
//     EndDocPrinter(pHandle.value);
//     ClosePrinter(pHandle.value);
//
//     // تحرير الذاكرة المخصصة
//     calloc.free(printerNamePtr);
//     calloc.free(pHandle);
//     calloc.free(pDefaults);
//     calloc.free(docInfo);
//     calloc.free(dataPtr);
//     calloc.free(written);
//
//     print("تم إرسال التذكرة بنجاح");
//   } catch (e) {
//     print("Exception: $e");
//   }
// }