// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/widgets/new_pluto.dart';
// import '../../controllers/discount_pluto_edit_controller.dart';
// import '../../controllers/invoice_controller.dart';
// import '../../controllers/invoice_pluto_edit_controller.dart';
// import 'invoice_screen.dart';
//
// class AllInvoice extends StatelessWidget {
//   const AllInvoice({super.key, required this.listDate, required this.productName});
//
//   final List<String> listDate;
//   final String? productName;
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<InvoiceController>(builder: (controller) {
//       return CustomPlutoGridWithAppBar(
//         title: "جميع الفواتير",
//         type: AppConstants.globalTypeInvoice,
//         onLoaded: (e) {},
//         onSelected: (p0) {
//           print(p0.row?.cells["الرقم التسلسلي"]?.value);
//           Get.to(
//             () => InvoiceView(
//               billId: p0.row?.cells["الرقم التسلسلي"]?.value,
//               patternId: p0.row?.cells["النمط"]?.value,
//             ),
//             binding: BindingsBuilder(() {
//               Get.lazyPut(() => InvoicePlutoController());
//               Get.lazyPut(() => DiscountPlutoController());
//             }),
//           );
//         },
//       );
//     });
//   }
// }
