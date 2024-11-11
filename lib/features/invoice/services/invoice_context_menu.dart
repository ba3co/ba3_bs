import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/invoice/controllers/invoice_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/helper/enums/enums.dart';
import '../../../core/widgets/app_button.dart';
import '../../materials/data/models/material_model.dart';
import 'invoice_grid_service.dart';
import 'invoice_utils.dart';

class InvoiceContextMenu {
  InvoicePlutoController get invoicePlutoController => Get.find<InvoicePlutoController>();

  InvoiceGridService get invoiceGridService => invoicePlutoController.gridService;

  void showContextMenuSubTotal({
    required Offset tapPosition,
    required MaterialModel materialModel,
    required int index,
    required InvoiceUtils invoiceUtils,
  }) {
    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1.0,
        tapPosition.dy + 1.0,
      ),
      items: PriceType.values.map((type) {
        return showContextMenuItem(index, materialModel, type, invoiceUtils);
      }).toList(),
    );
  }

  PopupMenuItem showContextMenuItem(
    int index,
    MaterialModel materialModel,
    PriceType type,
    InvoiceUtils invoiceUtils,
  ) {
    return PopupMenuItem(
      enabled: true,
      child: ListTile(
        title: Text(
          '${type.label}: ${invoiceUtils.getPrice(type: type, materialModel: materialModel).toStringAsFixed(2)}',
          textDirection: TextDirection.rtl,
        ),
      ),
      onTap: () {
        invoiceGridService.updateInvoiceValues(
          invoiceUtils.getPrice(materialModel: materialModel, type: type),
          int.tryParse(invoicePlutoController
                      .mainTableStateManager.rows[index].cells[AppConstants.invRecQuantity]?.value
                      .toString() ??
                  '1') ??
              1,
        );
        invoicePlutoController.update();
      },
    );
  }

  void showDeleteConfirmationDialog(int index) {
    Get.defaultDialog(
      title: AppConstants.deleteConfirmationTitle,
      content: const Text(AppConstants.deleteConfirmationMessage),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            AppButton(
              title: AppConstants.yes,
              onPressed: () => _deleteRow(index),
              color: Colors.red,
              iconData: Icons.check,
              width: 80,
            ),
            const HorizontalSpace(20),
            AppButton(
              title: AppConstants.no,
              onPressed: Get.back,
              iconData: Icons.clear,
              width: 80,
            ),
          ],
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
