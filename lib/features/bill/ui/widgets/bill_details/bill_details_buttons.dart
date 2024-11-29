import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_assets.dart';
import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../../data/models/bill_model.dart';
import '../bill_shared/show_e_invoice_dialog.dart';

class BillDetailsButtons extends StatelessWidget {
  const BillDetailsButtons({
    super.key,
    required this.billDetailsController,
    required this.billModel,
    required this.fromBillById,
  });

  final BillDetailsController billDetailsController;
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
          AppButton(
            title: 'جديد',
            onPressed: () {
              billDetailsController.createNewFloatingAddBillScreen(
                billModel.billTypeModel,
                context,
                fromBillDetails: true,
                fromBillById: fromBillById,
              );
            },
            iconData: Icons.create_new_folder_outlined,
          ),
          AppButton(
            title: 'السند',
            onPressed: () async {
              billDetailsController.createBond(billModel.billTypeModel);
            },
            iconData: Icons.file_open_outlined,
          ),
          AppButton(
            title: "تعديل",
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
            onPressed: () async {
              billDetailsController.printBill(
                billNumber: billModel.billDetails.billNumber!,
                invRecords: Get.find<BillDetailsPlutoController>().generateBillRecords,
              );
            },
          ),
          AppButton(
            title: 'E-Invoice',
            onPressed: () {
              showEInvoiceDialog(billDetailsController, billModel.billId!);
            },
            iconData: Icons.link,
          ),
          AppButton(
            title: 'Pdf-Email',
            fontSize: 15,
            onPressed: () {
              billDetailsController.generateAndSendBillPdf(
                recipientEmail: AppStrings.recipientEmail,
                billModel: billModel,
                fileName: AppStrings.bill,
                logoSrc: AppAssets.ba3Logo,
                fontSrc: AppAssets.notoSansArabicRegular,
              );
            },
            iconData: Icons.link,
          ),
          AppButton(
            iconData: Icons.delete_outline,
            color: Colors.red,
            title: 'حذف',
            onPressed: () async {
              billDetailsController.deleteBill(
                billModel.billId!,
                fromBillById: fromBillById,
              );
            },
          ),
        ],
      ),
    );
  }
}
