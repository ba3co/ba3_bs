// import 'package:ba3_business_solutions/controller/account_controller.dart';
// import 'package:ba3_business_solutions/controller/pattern_controller.dart';
// import 'package:ba3_business_solutions/model/account_model.dart';
// import 'package:ba3_business_solutions/view/products/widget/product_details_page.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:syncfusion_flutter_datagrid/datagrid.dart';
//
// import '../../../Const/app_constants.dart';
// import '../../../controller/invoice_controller.dart';
// import '../../../controller/product_controller.dart';
// import '../../../model/invoice_discount_record_model.dart';
// import '../../../model/material_model.dart';
//
// class InvoiceDiscountRecordSource extends DataGridSource {
//   dynamic newCellValue;
//   TextEditingController editingController = TextEditingController();
//   double total = 0.0;
//
//   final invoiceViewModel = Get.find<InvoiceViewModel>();
//   final productController = Get.find<ProductViewModel>();
//   final patternController = Get.find<PatternViewModel>();
//
//   List<InvoiceDiscountRecordModel> records;
//   AccountModel? secAccountModel;
//   bool? isPatternHasVat;
//
//   InvoiceDiscountRecordSource({required this.records}) {
//     buildDataGridRows(records);
//   }
//
//   void buildDataGridRows(List<InvoiceDiscountRecordModel> records) {
//     dataGridRows = records
//         .map<DataGridRow>((dataGridRow) {
//           // if(dataGridRow.discountId!=null){
//           //   if(dataGridRow.isChooseTotal==true){
//           //     dataGridRow.percentage = dataGridRow.total! / totalWithoutVat!;
//           //   }else if(dataGridRow.isChooseTotal==false){
//           //     dataGridRow.total = totalWithoutVat! * dataGridRow.percentage! / 100;
//           //   }
//           // }
//           return DataGridRow(cells: [
//             DataGridCell<int>(columnName: Const.rowInvDiscountId, value: dataGridRow.discountId),
//             DataGridCell<String>(columnName: Const.rowInvDiscountAccount, value: getAccountNameFromId(dataGridRow.accountId)),
//             DataGridCell<double>(columnName: Const.rowInvDisAddedTotal, value: dataGridRow.addedTotal),
//             DataGridCell<double>(columnName: Const.rowInvDisAddedPercentage, value: dataGridRow.addedPercentage),
//              DataGridCell<double>(columnName: Const.rowInvDisAddedTotal, value: dataGridRow.discountTotal),
//             DataGridCell<double>(columnName: Const.rowInvDisDiscountPercentage, value: dataGridRow.discountPercentage),
//           ]);
//     })
//         .toList();
//   }
//
//   late List<DataGridRow> dataGridRows;
//
//   @override
//   Future<void> onCellSubmit(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
//     // final dynamic oldValue = dataGridRow.getCells().firstWhereOrNull((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName)?.value ?? '';
//     final int dataRowIndex = dataGridRows.indexOf(dataGridRow);
//     if(records[dataRowIndex].discountId == null){
//       records[dataRowIndex].discountId = (dataRowIndex + 1);
//       records[dataRowIndex].addedPercentage=0;
//       records[dataRowIndex].addedTotal=0;
//       records[dataRowIndex].discountTotal=0;
//       records[dataRowIndex].discountPercentage=0;
//     }
//     if (column.columnName == Const.rowInvDiscountAccount) {
//       AccountModel? _ = await getAccountCompleteID(newCellValue);
//       if(_!=null){
//         records[dataRowIndex].accountId =_.accId;
//         invoiceViewModel.onDiscountCellTap(rowColumnIndex);
//         buildDataGridRows(records);
//         updateDataGridSource();
//       }
//     }else if(records[dataRowIndex].accountId!=null&&newCellValue!=null){
//       if(column.columnName == Const.rowInvDisDiscountTotal){
//
//         records[dataRowIndex].discountPercentage =invoiceViewModel.getPercentage(double.parse(newCellValue));
//         if(records[dataRowIndex].discountPercentage!>100){}else{
//           records[dataRowIndex].discountTotal =double.parse(newCellValue);
//           records[dataRowIndex].isChooseDiscountTotal =true;
//           invoiceViewModel.onDiscountCellTap(rowColumnIndex);
//           buildDataGridRows(records);
//           updateDataGridSource();
//         }
//       }else if(column.columnName == Const.rowInvDisDiscountPercentage){
//         if(double.parse(newCellValue)>100){}else{
//         records[dataRowIndex].discountPercentage =double.parse(newCellValue);
//         records[dataRowIndex].isChooseDiscountTotal =false;
//         records[dataRowIndex].discountTotal =invoiceViewModel.getTotal(double.parse(newCellValue));
//         invoiceViewModel.onDiscountCellTap(rowColumnIndex);
//         buildDataGridRows(records);
//         updateDataGridSource();
//         }
//       }else  if(column.columnName == Const.rowInvDisAddedTotal){
//
//         records[dataRowIndex].addedPercentage =invoiceViewModel.getPercentage(double.parse(newCellValue));
//         if(records[dataRowIndex].addedPercentage!>100){}else{
//           records[dataRowIndex].addedTotal =double.parse(newCellValue);
//           records[dataRowIndex].isChooseAddedTotal =true;
//           invoiceViewModel.onDiscountCellTap(rowColumnIndex);
//           buildDataGridRows(records);
//           updateDataGridSource();
//         }
//       }else if(column.columnName == Const.rowInvDisAddedPercentage){
//         if(double.parse(newCellValue)>100){}else{
//         records[dataRowIndex].addedPercentage =double.parse(newCellValue);
//         records[dataRowIndex].isChooseAddedTotal =false;
//         records[dataRowIndex].addedTotal =invoiceViewModel.getTotal(double.parse(newCellValue));
//         invoiceViewModel.onDiscountCellTap(rowColumnIndex);
//         buildDataGridRows(records);
//         updateDataGridSource();
//         }
//       }
//     }
//     invoiceViewModel.update();
//   }
//
//   @override
//   Widget? buildEditWidget(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column, CellSubmit submitCell) {
//     String displayText = dataGridRow.getCells().firstWhereOrNull((DataGridCell dataGridCell) => dataGridCell.columnName == column.columnName)?.value?.toString() ?? '';
//
//     newCellValue = null;
//
//     final bool isNumericType = column.columnName == 'subTotal' || column.columnName == 'total';
//     final bool isIntType = column.columnName == 'quantity';
//     if (double.tryParse(displayText) != null) {
//       displayText = double.parse(displayText).toStringAsFixed(2);
//     }
//     return Container(
//       color: effectiveRows.indexOf(dataGridRow) % 2 == 0 ? Colors.grey.withOpacity(0.2) : Colors.grey,
//       padding: const EdgeInsets.all(8.0),
//       child: TextField(
//         autofocus: true,
//         controller: editingController..text = displayText,
//         decoration:  InputDecoration(
//           fillColor: Colors.black,
//           contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 16.0),
//         ),
//         keyboardType: TextInputType.text,
//         onChanged: (String value) {
//           if (value.isNotEmpty) {
//             if (isNumericType) {
//               newCellValue = double.parse(value);
//             } else if (isIntType) {
//               newCellValue = int.parse(value);
//             } else {
//               newCellValue = value;
//             }
//           } else {
//             newCellValue = null;
//           }
//         },
//         onSubmitted: (String value) {
//           submitCell();
//         },
//       ),
//     );
//   }
//
//   @override
//   List<DataGridRow> get rows => dataGridRows;
//
//
//   @override
//   DataGridRowAdapter? buildRow(DataGridRow row) {
//     Color getRowBackgroundColor() {
//       final int index = effectiveRows.indexOf(row);
//       if (index % 2 == 0) {
//         return  Colors.white;
//       }
//
//       return Colors.blueAccent.shade200;
//     }
//
//     return DataGridRowAdapter(
//         cells: row.getCells().map<Widget>((dataGridCell) {
//       return GestureDetector(
//         onSecondaryTapDown: (_) {
//           var productName = row.getCells().firstWhereOrNull((element) => element.columnName == Const.rowInvProduct);
//           if (productName?.value != null) {
//             var prodItem = productController.productDataMap.values.firstWhere((element) => element.prodName == productName?.value);
//             if (dataGridCell.columnName == Const.rowInvProduct) {
//               showContextMenuProductName(_.globalPosition, prodItem.prodId, effectiveRows.indexOf(row));
//             } else if (dataGridCell.columnName == Const.rowInvSubTotal) {
//               showContextMenuSubTotal(_.globalPosition, prodItem, effectiveRows.indexOf(row), isPatternHasVat!);
//             }
//           }
//         },
//         onLongPressStart: (_) {
//           var productName = row.getCells().firstWhereOrNull((element) => element.columnName == Const.rowInvProduct);
//           if (productName?.value != null) {
//             var prodItem = productController.productDataMap.values.firstWhere((element) => element.prodName == productName?.value);
//             if (dataGridCell.columnName == Const.rowInvProduct) {
//               showContextMenuProductName(_.globalPosition, prodItem.prodId, effectiveRows.indexOf(row));
//             } else if (dataGridCell.columnName == Const.rowInvSubTotal) {
//               showContextMenuSubTotal(_.globalPosition, prodItem, effectiveRows.indexOf(row), isPatternHasVat!);
//             }
//           }
//         },
//         child: Container(
//           color: getRowBackgroundColor(),
//           alignment: Alignment.center,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: Text(dataGridCell.value == null
//                     ? ""
//                     : dataGridCell.value.runtimeType == double
//                         ? dataGridCell.value.toStringAsFixed(2)
//                         : dataGridCell.value.toString(),textAlign: TextAlign.center,),
//               ),
//               if(dataGridCell.columnName == Const.rowInvDisDiscountPercentage ||dataGridCell.columnName == Const.rowInvDisAddedPercentage )
//                 Text("%",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
//               SizedBox(width: 10,),
//             ],
//           ),
//         ),
//       );
//     }).toList());
//   }
//
//   void updateDataGridSource() {
//     // computeTotal();
//     notifyListeners();
//   }
//
//   // double computeTotal() {
//   //   int quantity = 0;
//   //   double subtotals = 0.0;
//   //   total = 0.0;
//   //   for (var record in records) {
//   //     if (record.invRecQuantity != null && record.invRecSubTotal != null) {
//   //       quantity = record.invRecQuantity!;
//   //       subtotals = record.invRecSubTotal!;
//   //       total += quantity * (subtotals + record.invRecVat!);
//   //     }
//   //   }
//   //   return total;
//   // }
//
//
//   @override
//   Future<bool> canSubmitCell(DataGridRow dataGridRow, RowColumnIndex rowColumnIndex, GridColumn column) async {
//     return true;
//   }
//
//   void showContextMenuProductName(Offset tapPosition, productId, int index) {
//     //final RenderBox overlay = Overlay.of(Get.context!)!.context.findRenderObject() as RenderBox;
//     showMenu(
//       context: Get.context!,
//       position: RelativeRect.fromLTRB(
//         tapPosition.dx,
//         tapPosition.dy,
//         tapPosition.dx + 1.0,
//         tapPosition.dy + 1.0,
//       ),
//       items: [
//         PopupMenuItem(
//           child: ListTile(
//             leading: Icon(Icons.golf_course),
//             title: Text('عرض حركات المادة'),
//           ),
//           value: 'product',
//         ),
//         PopupMenuItem(
//           child: ListTile(
//             leading: Icon(
//               Icons.close,
//               color: Colors.red,
//             ),
//             title: Text('حذف المادة'),
//           ),
//           value: 'delete',
//         ),
//       ],
//     ).then((value) {
//       if (value == 'product') {
//         Get.to(ProductDetails(
//           oldKey: productId,
//         ));
//       }
//       if (value == 'delete') {
//         invoiceViewModel.deleteOneRecord(index);
//       }
//     });
//   }
//
//   void showContextMenuSubTotal(Offset tapPosition, ProductModel productModel, int index, bool isPatternHasVat) {
//     showMenu(
//       // 457
//       context: Get.context!,
//       position: RelativeRect.fromLTRB(
//         tapPosition.dx,
//         tapPosition.dy,
//         tapPosition.dx + 1.0,
//         tapPosition.dy + 1.0,
//       ),
//       items: [
//         showContextMenuItem(index, 'حذف'),
//       ],
//     );
//   }
//
//   PopupMenuItem showContextMenuItem(index, text) {
//     return PopupMenuItem(
//       onTap: () {},
//       enabled: true,
//       child: ListTile(
//         leading: Icon(Icons.delete,color: Colors.red,),
//         title: Text(
//           text,
//           textDirection: TextDirection.rtl,
//         ),
//       ),
//     );
//   }
// }
