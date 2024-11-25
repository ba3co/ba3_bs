import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../materials/data/models/material_model.dart';
import 'bill_pluto_grid_service.dart';
import 'bill_pluto_utils.dart';

class BillPlutoContextMenu {
  final IPlutoController controller;

  BillPlutoContextMenu(this.controller);

  void showContextMenuSubTotal({
    required Offset tapPosition,
    required MaterialModel materialModel,
    required int index,
    required BillPlutoUtils invoiceUtils,
    required BillPlutoGridService gridService,
  }) {
    showMenu(
      context: Get.context!,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1.0,
        tapPosition.dy + 1.0,
      ),
      items: PriceType.values
          .map((type) => showContextMenuItem(index, materialModel, type, invoiceUtils, gridService))
          .toList(),
    );
  }

  PopupMenuItem showContextMenuItem(
    int index,
    MaterialModel materialModel,
    PriceType type,
    BillPlutoUtils invoiceUtils,
    BillPlutoGridService gridService,
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
        gridService.updateInvoiceValues(
          invoiceUtils.getPrice(type: type, materialModel: materialModel),
          int.tryParse(
                  controller.mainTableStateManager.rows[index].cells[AppConstants.invRecQuantity]?.value.toString() ??
                      '1') ??
              1,
        );
        controller.update();
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
    final rowToRemove = controller.mainTableStateManager.rows[rowIdx];
    controller.mainTableStateManager.removeRows([rowToRemove]);
    Get.back();
    controller.update();
  }
}
