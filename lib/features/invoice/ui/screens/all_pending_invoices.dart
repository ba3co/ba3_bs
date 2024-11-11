//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../core/constants/app_constants.dart';
// import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
// import '../../controllers/discount_pluto_edit_controller.dart';
// import '../../controllers/invoice_controller.dart';
// import '../../controllers/invoice_pluto_controller.dart';
// import 'invoice_screen.dart';
//
// class AllPendingInvoice extends StatelessWidget {
//   const AllPendingInvoice({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<InvoiceController>(builder: (controller) {
//       return controller.invoiceModel.values
//               .where(
//                 (e) => e.invIsPending!,
//               )
//               .isEmpty
//           ? Scaffold(
//               appBar: AppBar(),
//               body: const Center(
//                 child: Text("لا يوجد فواتيير غير مأكدة"),
//               ),
//             )
//           : CustomPlutoGridWithAppBar(
//               title: "جميع الفواتير",
//               onLoaded: (e) {},
//               type: AppConstants.globalTypeInvoice,
//               onSelected: (p0) {
//                 Get.to(
//                   () => InvoiceView(
//                     billId: p0.row?.cells["الرقم التسلسلي"]?.value,
//                     patternId: p0.row?.cells["النمط"]?.value,
//                   ),
//                   binding: BindingsBuilder(() {
//                     Get.lazyPut(() => InvoicePlutoController());
//                     Get.lazyPut(() => DiscountPlutoController());
//                   }),
//                 );
//               },
//
//             );
//     });
//   }
// }
//
