import 'package:ba3_bs/features/bill/controllers/bill/bill_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../../data/models/bill_model.dart';

class BillDetailsButtons extends StatelessWidget {
  const BillDetailsButtons({
    super.key,
    required this.billDetailsController,
    required this.billDetailsPlutoController,
    required this.billModel,
    required this.fromBillById,
    required this.billSearchController,
  });

  final BillDetailsController billDetailsController;
  final BillDetailsPlutoController billDetailsPlutoController;
  final BillSearchController billSearchController;
  final BillModel billModel;
  final bool fromBillById;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          if (billSearchController.isNew)
            Obx(() {
              return AppButton(
                  title: 'إضافة',
                  height: 20,
                  color: billDetailsController.isBillSaved.value ? Colors.green : Colors.blue.shade700,
                  onPressed: billDetailsController.isBillSaved.value
                      ? () {}
                      : () async {
                          billDetailsController.saveBill(billModel.billTypeModel);
                        },
                  iconData: Icons.add_chart_outlined);
            }),
          AppButton(
            title: 'السند',
            height: 20,
            onPressed: () async {
              billDetailsController.createBond(billModel.billTypeModel, context);
            },
            iconData: Icons.file_open_outlined,
          ),
          if (!billSearchController.isNew)
            AppButton(
              title: "تعديل",
              height: 20,
              onPressed: () async {
                billDetailsController.updateBill(
                  billModel: billModel,
                  billTypeModel: billModel.billTypeModel,
                );
              },
              iconData: Icons.edit_outlined,
            ),
          AppButton(
            iconData: Icons.print_outlined,
            title: 'طباعة',
            height: 20,
            onPressed: () async {
              billDetailsController.printBill(
                billNumber: billModel.billDetails.billNumber!,
                invRecords: billDetailsPlutoController.generateRecords,
              );
            },
          ),
          AppButton(
            title: 'E-Invoice',
            height: 20,
            onPressed: () {
              billDetailsController.showEInvoiceDialog(billModel, context);
            },
            iconData: Icons.link,
          ),
          if (!billSearchController.isNew)
            AppButton(
              title: 'Pdf-Email',
              height: 20,
              onPressed: () {
                billDetailsController.generateAndSendBillPdf(billModel);
              },
              iconData: Icons.link,
            ),
          if (!billSearchController.isNew)
            AppButton(
              iconData: Icons.delete_outline,
              height: 20,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {
                billDetailsController.deleteBill(billModel, fromBillById: fromBillById);
              },
            ),
        ],
      ),
    );
  }
}
