import 'package:ba3_bs/features/invoice/controllers/add_invoice_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../patterns/data/models/bill_type_model.dart';
import '../../../controllers/invoice_pluto_controller.dart';

class AddBillButtons extends StatelessWidget {
  const AddBillButtons({
    super.key,
    required this.addInvoiceController,
    required this.billTypeModel,
  });

  final AddInvoiceController addInvoiceController;
  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    InvoicePlutoController invoicePlutoController = Get.find<InvoicePlutoController>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          AppButton(
              title: "إضافة",
              onPressed: () async {
                addInvoiceController.saveBill(billTypeModel: billTypeModel);
              },
              iconData: Icons.add_chart_outlined),
          AppButton(
              title: 'السند',
              onPressed: () async {
                addInvoiceController.createBond(billTypeModel);
              },
              iconData: Icons.file_open_outlined),
          AppButton(
            title: 'موافقة',
            onPressed: () async {},
            iconData: Icons.file_download_done_outlined,
            color: Colors.green,
          ),
          AppButton(title: "تعديل", onPressed: () async {}, iconData: Icons.edit_outlined),
          AppButton(
            title: "مبيعات",
            onPressed: () async {},
            iconData: Icons.done_all,
            color: Colors.green,
          ),
          ...[
            AppButton(
              iconData: Icons.print_outlined,
              title: 'طباعة',
              onPressed: () async {
                addInvoiceController.printInvoice(invoicePlutoController.generateInvoiceRecords);
              },
            ),
            AppButton(title: "E-Invoice", onPressed: () {}, iconData: Icons.link),
            AppButton(
              iconData: Icons.delete_outline,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {},
            )
          ],
        ],
      ),
    );
  }
}
