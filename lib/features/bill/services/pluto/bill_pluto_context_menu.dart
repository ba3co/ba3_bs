import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:flutter/material.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../materials/data/models/material_model.dart';
import 'bill_pluto_grid_service.dart';
import 'bill_pluto_utils.dart';

class BillPlutoContextMenu {
  final IPlutoController controller;

  BillPlutoContextMenu(this.controller);

  void showPriceTypeMenu({
    required BuildContext context,
    required Offset tapPosition,
    required MaterialModel materialModel,
    required BillPlutoUtils invoiceUtils,
    required BillPlutoGridService gridService,
    required int index,
  }) {
    OverlayService.showOverlayPopupMenu(
        context: context,
        tapPosition: tapPosition,
        items: PriceType.values,
        itemLabelBuilder: (type) =>
            '${type.label}: ${invoiceUtils.getPrice(type: type, materialModel: materialModel).toStringAsFixed(2)}',
        onSelected: (type) {
          gridService.updateInvoicePreviousRowValues(
              controller.mainTableStateManager.rows[index],
              invoiceUtils.getPrice(type: type, materialModel: materialModel),
              int.tryParse(
                    controller.mainTableStateManager.rows[index].cells[AppConstants.invRecQuantity]?.value.toString() ??
                        '1',
                  ) ??
                  1);
          controller.update();
        },
        onCloseCallback: () {
          debugPrint('PriceType menu closed.');
        });
  }

  void showDeleteConfirmationDialog(int index, BuildContext context) {
    OverlayService.showOverlayDialog(
      context: context,
      width: 280,
      height: 160,
      showDivider: false,
      borderRadius: BorderRadius.circular(20),
      title: AppConstants.deleteConfirmationTitle,
      content: Column(
        children: [
          const Spacer(),
          const Text(AppConstants.deleteConfirmationMessage),
          const VerticalSpace(15),
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
              const AppButton(
                title: AppConstants.no,
                onPressed: OverlayService.back,
                iconData: Icons.clear,
                width: 80,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _deleteRow(int rowIdx) {
    final rowToRemove = controller.mainTableStateManager.rows[rowIdx];
    controller.mainTableStateManager.removeRows([rowToRemove]);
    OverlayService.back();
    controller.update();
  }
}
