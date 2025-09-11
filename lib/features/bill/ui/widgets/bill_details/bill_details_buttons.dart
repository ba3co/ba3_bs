import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_model_extensions.dart';
import 'package:ba3_bs/core/styling/app_text_style.dart';

import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/bill/bill_pattern_type_extension.dart';
import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../users_management/data/models/role_model.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../../data/models/bill_model.dart';

class BillDetailsButtons extends StatelessWidget {
  const BillDetailsButtons({
    super.key,
    required this.billDetailsController,
    required this.billDetailsPlutoController,
    required this.billSearchController,
    required this.billModel,
  });

  final BillDetailsController billDetailsController;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;
  final BillModel billModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: 1.sw,
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 20,
          runSpacing: 20,
          children: [
            //  if (!billDetailsController.isBillSaved.value) _buildAddAndPrintButton(context),
            _buildAddButton(context),
            if ((!billSearchController.isNew) &&
                (billModel.billTypeModel.billPatternType!.hasCashesAccount || billSearchController.isPending))
              _buildApprovalOrBondButton(context),
            if (!billSearchController.isPending)
              _buildActionButton(
                title: AppStrings.print.tr,
                icon: FontAwesomeIcons.print,
                onPressed: () => billDetailsController.printBill(
                  context: context,
                  billModel: billModel,
                  invRecords: billDetailsPlutoController.generateRecords,
                ),
              ),
            if (!billSearchController.isPending)
              _buildActionButton(
                title: AppStrings.eInvoice.tr,
                icon: FontAwesomeIcons.fileLines,
                onPressed: () => billDetailsController.showEInvoiceDialog(billModel, context),
              ),
            if (!billSearchController.isNew) ..._buildEditDeletePdfButtons(context),
            Visibility(
              visible: RoleItemType.administrator.hasReadPermission,
              child: _buildActionButton(
                title: AppStrings.viewProducts.tr,
                icon: FontAwesomeIcons.streetView,
                width: 120,
                onPressed: () => billDetailsController.changeBillPlutoView(billModel, context),
              ),
            ),
            Visibility(
                visible: billModel.billTypeModel.isPurchaseRelated, child: freeLocalSwitcher(billDetailsController: billDetailsController)),
            /*           Obx(() => !billDetailsController.isCash
                ? AppButton(
                    height: 20,
                    fontSize: 14,
                    title: AppStrings.more.tr,
                    onPressed: () {
                      billDetailsController.openFirstPayDialog(context);
                    })
                : SizedBox.shrink()),*/
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Obx(() {
      final isBillSaved = billDetailsController.isBillSaved.value;
      return AppButton(
        title: isBillSaved ? AppStrings.newS.tr : AppStrings.save.tr,
        height: 20,
        fontSize: 14,
        width: 90,
        isLoading: billDetailsController.saveBillRequestState.value == RequestState.loading,
        color: isBillSaved ? Colors.green : Colors.blue.shade700,
        onPressed: isBillSaved
            ? () => billDetailsController.appendNewBill(
                billTypeModel: billModel.billTypeModel, lastBillNumber: billSearchController.bills.last.billDetails.billNumber!)
            : () => billDetailsController.saveBill(billModel.billTypeModel, context: context, withPrint: false),
        iconData: FontAwesomeIcons.floppyDisk,
      );
    });
  }

  // Widget _buildAddAndPrintButton(BuildContext context) {
  //   return Obx(() {
  //     final isBillSaved = billDetailsController.isBillSaved.value;
  //     return AppButton(
  //       title: isBillSaved ? AppStrings.newS.tr : AppStrings.add.tr,
  //       height: 20,
  //       width: 90,
  //       fontSize: 14,
  //       color: Colors.blue.shade700,
  //       onPressed: () async => await billDetailsController.saveBill(billModel.billTypeModel, context: context, withPrint: true),
  //       iconData: FontAwesomeIcons.plusSquare,
  //     );
  //   });
  // }

  Widget _buildApprovalOrBondButton(BuildContext context) {
    final isPending = billSearchController.isPending;
    return _buildActionButton(
      title: isPending ? AppStrings.approve.tr : AppStrings.bond.tr,
      icon: FontAwesomeIcons.check,
      color: isPending ? Colors.orange : null,
      onPressed: isPending
          ? () => billDetailsController.updateBillStatus(billModel, Status.approved, context)
          : () => billDetailsController.launchFloatingEntryBondDetailsScreen(billModel, context),
    );
  }

  List<Widget> _buildEditDeletePdfButtons(BuildContext context) {
    return [
      if (!billSearchController.isPending)
        Obx(() {
          return _buildActionButton(
            isLoading: billDetailsController.saveBillRequestState.value == RequestState.loading,
            title: AppStrings.edit.tr,
            icon: FontAwesomeIcons.solidPenToSquare,
            onPressed: () => billDetailsController.updateBill(
                context: context, billModel: billModel, billTypeModel: billModel.billTypeModel, withPrint: false),
          );
        }),
      if (!billSearchController.isPending)
        _buildActionButton(
          title: AppStrings.pdfEmail.tr,
          icon: FontAwesomeIcons.solidEnvelope,
          onPressed: () => billDetailsController.generateAndSendBillPdfToEmail(billModel, context),
        ),
      if (!billSearchController.isPending)
        _buildActionButton(
          title: AppStrings.printLabelPdf.tr,
          icon: FontAwesomeIcons.solidEnvelope,
          onPressed: () => billDetailsController.generateAndSaveBillLabel(billModel, context),
        ),
      if (!billSearchController.isPending)
        _buildActionButton(
          title: AppStrings.whatsApp.tr,
          icon: FontAwesomeIcons.whatsapp,
          onPressed: () => billDetailsController.sendBillToWhatsapp(billModel, context),
        ),
      Obx(() {
        return _buildActionButton(
          isLoading: billDetailsController.deleteBillRequestState.value == RequestState.loading,
          title: AppStrings.delete.tr,
          icon: FontAwesomeIcons.eraser,
          color: Colors.red,
          onPressed: () => billDetailsController.deleteBill(billModel, context),
        );
      }),
    ];
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
    bool isLoading = false,
    Color? color,
    double? width,
  }) {
    return AppButton(
      isLoading: isLoading,
      title: title,
      iconData: icon,
      height: 20,
      width: width ?? 90,
      fontSize: 14,
      color: color ?? Colors.blue.shade700,
      onPressed: onPressed,
    );
  }

  /* Widget freeLocalSwitcher(
      {required BillDetailsController billDetailsController}) {
    log('freeLocalSwitcher ${billDetailsController.advancedSwitchController.value}');
    return AdvancedSwitch(
      controller: billDetailsController.advancedSwitchController,
      activeColor: Colors.green,
      inactiveColor: Colors.grey,
      inactiveChild: Text('فري'),
      activeChild: Text('لوكال'),
      borderRadius: BorderRadius.all(Radius.circular(15)),
      width: 100.0,
      height: 30.0,
      enabled: true,
      disabledOpacity: 0.5,
      onChanged: (value) {
        // Update the switch state in the GetX controller.
        billDetailsController.updateSwitch(value);
      },
    );
  } */
  Widget freeLocalSwitcher({required BillDetailsController billDetailsController}) {
    return AnimatedToggleSwitch<bool>.dual(
      current: billDetailsController.advancedSwitchController.value,
      first: true,
      second: false,
      spacing: 30.0,
      style: ToggleStyle(
        borderColor: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1.5),
          ),
        ],
      ),
      borderWidth: 2.0,
      height: 40,
      onChanged: (value) => billDetailsController.updateSwitch(value),
      styleBuilder: (value) => ToggleStyle(indicatorColor: value ? Colors.red : Colors.amber),
      // iconBuilder: (value) => value ? const Icon(Icons.coronavirus_rounded) : const Icon(Icons.tag_faces_rounded),
      textBuilder: (value) => value
          ? Center(
              child: Text(
              'فري',
              style: AppTextStyles.headLineStyle3,
            ))
          : Center(
              child: Text(
              'لوكال',
              style: AppTextStyles.headLineStyle3,
            )),
    );
  }
}