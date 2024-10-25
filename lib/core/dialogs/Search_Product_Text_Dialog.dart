// import 'package:ba3_business_solutions/data/model/product/product_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../../../../core/shared/widgets/new_pluto.dart';
// import '../../../controller/product/product_controller.dart';
// import '../../../view/invoices/widget/custom_Text_field.dart';
// import '../../constants/app_constants.dart';
// import '../../features/invoice/ui/widgets/custom_Text_field.dart';
// import '../constants/app_constants.dart';
// import '../widgets/new_pluto.dart';
//
// Future<String?> searchProductTextDialog(String productText) async {
//   TextEditingController productTextController = TextEditingController()..text = productText;
//
//   // List<ProductModel> productsForSearch;
//   //
//   // productsForSearch = Get.find<ProductController>().searchOfProductByText(productTextController.text, false);
//
//   if (productsForSearch.length == 1) {
//     return productsForSearch.first.prodName!;
//   } else if (productsForSearch.isEmpty) {
//     return null;
//   } else {
//     await showDialog<String>(
//         context: Get.context!,
//         builder: (BuildContext context) => Dialog(
//               child: GetBuilder<ProductController>(builder: (productViewModel) {
//                 return Directionality(
//                   textDirection: TextDirection.rtl,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: <Widget>[
//                       SizedBox(
//                           height: Get.height / 1.5,
//                           child: ClipRRect(
//                             clipBehavior: Clip.hardEdge,
//                             borderRadius: BorderRadius.circular(15),
//                             child: CustomPlutoGridWithAppBar(
//                               type: AppConstants.prodViewTypeSearch,
//                               onSelected: (selected) {
//                                 // productTextController.text = getProductNameFromId(selected.row?.cells["الرقم التسلسلي"]!.value);
//                                 // Get.back();
//                               },
//                               title: "اختيار مادة",
//                               modelList: productsForSearch,
//                               onLoaded: (p0) {},
//                             ),
//                           )),
//                       Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: CustomTextFieldWithIcon(
//                             controller: productTextController,
//                             onSubmitted: (_) async {
//                               // productsForSearch = productViewModel.searchOfProductByText(productTextController.text, false);
//                               // productViewModel.update();
//                             },
//                             onIconPressed: () {}),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ));
//
//     return productTextController.text;
//   }
// }
