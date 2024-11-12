import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../login/controllers/user_management_controller.dart';
import '../../../controllers/invoice_controller.dart';
import '../../../controllers/invoice_pluto_controller.dart';
import '../../../data/models/bill_model.dart';

class BillDetailsButtons extends StatelessWidget {
  const BillDetailsButtons({super.key, required this.invoiceController, required this.billModel});

  final InvoiceController invoiceController;
  final BillModel billModel;

  @override
  Widget build(BuildContext context) {
    var invoicePlutoController = Get.find<InvoicePlutoController>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          AppButton(
              title: 'جديد',
              onPressed: () async {
                hasPermissionForOperation(AppConstants.roleUserWrite, AppConstants.roleViewInvoice).then((value) {
                  if (value) {}
                });
              },
              iconData: Icons.create_new_folder_outlined),
          AppButton(
              title: 'السند',
              onPressed: () async {
                invoiceController.createBond(billModel.billTypeModel);
              },
              iconData: Icons.file_open_outlined),
          AppButton(
              title: "تعديل",
              onPressed: () async {
                invoiceController.saveBill(billModel: billModel, billTypeModel: billModel.billTypeModel, isEdit: true);
              },
              iconData: Icons.edit_outlined),
          ...[
            AppButton(
              iconData: Icons.print_outlined,
              title: 'طباعة',
              onPressed: () async {
                invoiceController.printInvoice(invoicePlutoController.generateInvoiceRecords);
              },
            ),
            AppButton(title: "E-Invoice", onPressed: () {}, iconData: Icons.link),
            AppButton(
              iconData: Icons.delete_outline,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {
                invoiceController.deleteBill(billModel.billId!);
              },
            )
          ],
        ],
      ),
    );
  }
}
