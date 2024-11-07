import 'package:ba3_bs/features/bond/controllers/bond_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../../login/controllers/user_management_controller.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../../../controllers/invoice_controller.dart';
import '../../../controllers/invoice_pluto_controller.dart';

class BillDetailsButtons extends StatelessWidget {
  const BillDetailsButtons({
    super.key,
    required this.invoiceController,
    required this.billTypeModel,
    required this.billId,
  });

  final InvoiceController invoiceController;
  final BillTypeModel billTypeModel;
  final String billId;

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
                if (!invoiceController.validateForm()) return;

                Get.find<BondController>().createBond(
                  billTypeModel: billTypeModel,
                  vat: invoicePlutoController.computeTotalVat,
                  customerAccount: invoiceController.selectedCustomerAccount!,
                  total: invoicePlutoController.computeWithoutVatTotal,
                  gifts: invoicePlutoController.computeGifts,
                  discount: invoicePlutoController.computeDiscounts,
                  addition: invoicePlutoController.computeAdditions,
                );
              },
              iconData: Icons.file_open_outlined),
          AppButton(title: "تعديل", onPressed: () async {}, iconData: Icons.edit_outlined),
          ...[
            AppButton(
              iconData: Icons.print_outlined,
              title: 'طباعة',
              onPressed: () async {
                invoiceController.printInvoice(invoicePlutoController.handleSaveAllMaterials());
              },
            ),
            AppButton(title: "E-Invoice", onPressed: () {}, iconData: Icons.link),
            AppButton(
              iconData: Icons.delete_outline,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {
                invoiceController.deleteInvoice(billId);
              },
            )
          ],
        ],
      ),
    );
  }
}
