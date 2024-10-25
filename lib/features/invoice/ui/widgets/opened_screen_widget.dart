// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
//
// import '../../../patterns/controllers/pattern_controller.dart';
//
//
// class OpenedScreenWidget extends StatelessWidget {
//   const OpenedScreenWidget({super.key, required this.patternController});
//
//   final PatternController patternController;
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<ScreenController>(builder: (screenController) {
//       return Padding(
//         padding: const EdgeInsets.all(15.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "الفواتيير المفتوحة"
//               "(${screenController.openedScreen.length})",
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(
//               height: 15,
//             ),
//             Wrap(
//               spacing: 15.0,
//               runSpacing: 15.0,
//               children: screenController.openedScreen.entries.toList().map((i) {
//                 return Stack(
//                   clipBehavior: Clip.none,
//                   children: [
//                     InkWell(
//                       onTap: () {
//                         SystemChrome.setPreferredOrientations([
//                           DeviceOrientation.landscapeLeft,
//                         ]);
//                         // print(i.toFullJson());
//                         Get.to(
//                           () => InvoiceView(
//                             billId: i.key,
//                             patternId: i.value.patternId!,
//                             recentScreen: true,
//                           ),
//                           binding: BindingsBuilder(() {
//                             Get.lazyPut(() => InvoicePlutoController());
//                             // Get.lazyPut(() => DiscountPlutoViewModel());
//                           }),
//                         );
//                         /*               Get.to(() => InvoiceView(
//                                       billId: i.key,
//                                       patternId: i.value.patternId!,
//                                       recentScreen: true,
//                                     ));*/
//                       },
//                       child: Container(
//                         // width: 300,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(20),
//                           color: Colors.white,
//                           border: Border.all(
//                             color: Color(patternController.patternModel[i.value.patternId]?.patColor! ?? 00000).withOpacity(0.5),
//                             width: 1.0,
//                           ),
//                         ),
//                         padding: const EdgeInsets.all(8.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const SizedBox(
//                                   width: 120,
//                                   child: Text(
//                                     "نمط الفاتورة:",
//                                     style: TextStyle(fontSize: 16),
//                                     textDirection: TextDirection.rtl,
//                                   ),
//                                 ),
//                                 SizedBox(
//                                   child: Text(
//                                     patternController.patternModel[i.value.patternId!]!.patName ?? "error",
//                                     style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                                     textDirection: TextDirection.rtl,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const SizedBox(
//                                   width: 120,
//                                   child: Text(
//                                     "رقم الفاتورة:",
//                                     style: TextStyle(fontSize: 18),
//                                     textDirection: TextDirection.rtl,
//                                   ),
//                                 ),
//                                 Text(
//                                   i.value.invCode.toString(),
//                                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
//                                   textDirection: TextDirection.rtl,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const SizedBox(
//                                   width: 120,
//                                   child: Text(
//                                     "وقت الفاتورة:",
//                                     style: TextStyle(fontSize: 18),
//                                     textDirection: TextDirection.rtl,
//                                   ),
//                                 ),
//                                 Text(
//                                   i.value.invDate.toString().split(" ")[1],
//                                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
//                                   textDirection: TextDirection.rtl,
//                                 ),
//                               ],
//                             ),
//                             const SizedBox(
//                               height: 5,
//                             ),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 const SizedBox(
//                                   width: 120,
//                                   child: Text(
//                                     "مجموع الفاتورة:",
//                                     style: TextStyle(fontSize: 18),
//                                     textDirection: TextDirection.rtl,
//                                   ),
//                                 ),
//                                 Text(
//                                   formatDecimalNumberWithCommas(i.value.invTotal ?? 0),
//                                   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
//                                   textDirection: TextDirection.rtl,
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                         top: -5,
//                         left: -1,
//                         child: GestureDetector(
//                           onTap: () {
//                             screenController.openedScreen.remove(i.key);
//                             screenController.update();
//                           },
//                           child: Container(
//                               padding: const EdgeInsets.all(5),
//                               decoration: BoxDecoration(
//                                   color: Colors.red.shade800,
//                                   shape: BoxShape.circle,
//                                   boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 10, spreadRadius: 0.2)]),
//                               child: const Icon(
//                                 Icons.close,
//                                 size: 13,
//                                 color: Colors.white,
//                               )),
//                         ))
//                   ],
//                 );
//               }).toList(),
//             ),
//           ],
//         ),
//       );
//     });
//   }
// }
