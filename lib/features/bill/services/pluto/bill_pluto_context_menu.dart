import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/utils/app_service_utils.dart';
import 'package:ba3_bs/core/widgets/app_spacer.dart';
import 'package:ba3_bs/features/floating_window/services/overlay_service.dart';
import 'package:ba3_bs/features/materials/controllers/mats_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';

import '../../../../core/helper/enums/enums.dart';
import '../../../../core/i_controllers/i_pluto_controller.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../materials/data/models/materials/material_model.dart';
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
    OverlayService.showPopupMenu(
        context: context,
        tapPosition: tapPosition,
        items: PriceType.values,
        itemLabelBuilder: (type) =>
            '${type.label}: ${invoiceUtils.getPrice(type: type, materialModel: materialModel).toStringAsFixed(2)}',
        onSelected: (PriceType type) {
          final PlutoRow selectedRow = controller.recordsTableStateManager.rows[index];
          final int quantity = AppServiceUtils.getItemQuantity(selectedRow);

          gridService.updateInvoiceValuesBySubTotal(
            selectedRow: selectedRow,
            subTotal: invoiceUtils.getPrice(type: type, materialModel: materialModel),
            quantity: quantity,
          );
          controller.update();
        },
        onCloseCallback: () {
          debugPrint('PriceType menu closed.');
        });
  }

  List<String> materialMenu = [
    'حركة المادة',
  ];

  void showMaterialMenu({
    required BuildContext context,
    required Offset tapPosition,
    required MaterialModel materialModel,
    required BillPlutoUtils invoiceUtils,
    required BillPlutoGridService gridService,
    required int index,
  }) {
    OverlayService.showPopupMenu(
        context: context,
        tapPosition: tapPosition,
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 8.0),
        items: materialMenu,
        itemLabelBuilder: (item) => item,
        onSelected: (String selectedMenuItem) {
          final PlutoRow selectedRow = controller.recordsTableStateManager.rows[index];
          final String matName = AppServiceUtils.getCellValue(selectedRow, AppConstants.invRecProduct);

          if (selectedMenuItem == 'حركة المادة') {
            read<MaterialsStatementController>().fetchMatStatements(matName, context: context);
          }
        },
        onCloseCallback: () {
          debugPrint('Material Menu closed.');
        });
  }

  void showDeleteConfirmationDialog(int index, BuildContext context) {
    OverlayService.showDialog(
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
    final rowToRemove = controller.recordsTableStateManager.rows[rowIdx];
    controller.recordsTableStateManager.removeRows([rowToRemove]);
    OverlayService.back();
    controller.update();
  }
}
