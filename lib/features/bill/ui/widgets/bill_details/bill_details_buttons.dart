import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../controllers/bill/bill_details_controller.dart';
import '../../../controllers/pluto/bill_details_pluto_controller.dart';
import '../../../data/models/bill_model.dart';

class BillDetailsButtons extends StatelessWidget {
  const BillDetailsButtons({super.key, required this.billDetailsController, required this.billModel});

  final BillDetailsController billDetailsController;
  final BillModel billModel;

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
              onPressed: () async {
                billDetailsController.navigateToAddBillScreen(
                  billModel.billTypeModel,
                  fromBillDetails: true,
                );
              },
              iconData: Icons.create_new_folder_outlined),
          AppButton(
              title: 'السند',
              onPressed: () async {
                billDetailsController.createBond(billModel.billTypeModel);
              },
              iconData: Icons.file_open_outlined),
          AppButton(
              title: "تعديل",
              onPressed: () async {
                billDetailsController.updateBill(billModel: billModel, billTypeModel: billModel.billTypeModel);
              },
              iconData: Icons.edit_outlined),
          ...[
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
            AppButton(title: "E-Invoice", onPressed: () {}, iconData: Icons.link),
            AppButton(
              iconData: Icons.delete_outline,
              color: Colors.red,
              title: 'حذف',
              onPressed: () async {
                billDetailsController.deleteBill(billModel.billId!);
              },
            )
          ],
        ],
      ),
    );
  }
}
