import 'package:ba3_bs/features/invoice/controllers/invoice_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../../materials/data/models/material_model.dart';
import 'invoice_grid_service.dart';
import 'invoice_utils.dart';

class InvoiceContextMenu {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  InvoiceGridService get invoiceGridService => invoicePlutoController.gridService;

  void showContextMenuSubTotal(
      {required Offset tapPosition,
      required MaterialModel materialModel,
      required int index,
      required InvoiceUtils invoiceUtils}) {
    final menuItems = [
      {'label': 'سعر المستهلك', 'method': AppConstants.invoiceChoosePriceMethodeCustomerPrice},
      {'label': 'سعر الجملة', 'method': AppConstants.invoiceChoosePriceMethodeWholePrice},
      {'label': 'سعر المفرق', 'method': AppConstants.invoiceChoosePriceMethodeRetailPrice},
    ];

    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1.0,
        tapPosition.dy + 1.0,
      ),
      items: menuItems.map((menuItem) {
        return showContextMenuItem(index, materialModel, menuItem['label']!, menuItem['method']!, invoiceUtils);
      }).toList(),
    );
  }

  PopupMenuItem showContextMenuItem(
      int index, MaterialModel materialModel, String text, String method, InvoiceUtils invoiceUtils) {
    return PopupMenuItem(
      enabled: true,
      child: ListTile(
        title: Text(
          "$text: ${invoiceUtils.getPrice(type: method, materialModel: materialModel).toStringAsFixed(2)}",
          textDirection: TextDirection.rtl,
        ),
      ),
      onTap: () {
        invoiceGridService.updateInvoiceValues(
          invoiceUtils.getPrice(materialModel: materialModel, type: method),
          int.tryParse(
                  invoicePlutoController.mainTableStateManager.rows[index].cells["invRecQuantity"]?.value.toString() ??
                      "1") ??
              1,
        );
        invoicePlutoController.update();
      },
    );
  }

  void showDeleteConfirmationDialog(int index) {
    Get.defaultDialog(
      title: "تأكيد الحذف",
      content: const Text("هل انت متأكد من حذف هذا العنصر"),
      actions: [
        AppButton(
          title: "نعم",
          onPressed: () => _deleteRow(index),
          iconData: Icons.check,
        ),
        AppButton(
          title: "لا",
          onPressed: Get.back,
          iconData: Icons.clear,
          color: Colors.red,
        ),
      ],
    );
  }

  void _deleteRow(int rowIdx) {
    final rowToRemove = invoicePlutoController.mainTableStateManager.rows[rowIdx];
    invoicePlutoController.mainTableStateManager.removeRows([rowToRemove]);
    Get.back();
    invoicePlutoController.update();
  }
}
