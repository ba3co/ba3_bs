import 'package:ba3_bs/features/bill/controllers/bill/add_bill_controller.dart';
import 'package:ba3_bs/features/bill/controllers/pluto/add_bill_pluto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/widgets/app_button.dart';
import '../../../../patterns/data/models/bill_type_model.dart';

class AddBillButtons extends StatelessWidget {
  const AddBillButtons({
    super.key,
    required this.addBillController,
    required this.billTypeModel,
  });

  final AddBillController addBillController;
  final BillTypeModel billTypeModel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.end,
        spacing: 20,
        runSpacing: 20,
        children: [
          Obx(() {
            final bool showAddNewBillButton = addBillController.showAddNewBillButton.value;
            return showAddNewBillButton
                ? AppButton(
                    title: 'جديد',
                    onPressed: () async {
                      addBillController.resetBillForm();
                    },
                    iconData: Icons.add_chart_outlined)
                : AppButton(
                    title: 'إضافة',
                    onPressed: () async {
                      addBillController.saveBill(billTypeModel);
                    },
                    iconData: Icons.add_chart_outlined);
          }),
          AppButton(
              title: 'السند',
              onPressed: () async {
                addBillController.createBond(billTypeModel);
              },
              iconData: Icons.file_open_outlined),
          ...[
            AppButton(
              iconData: Icons.print_outlined,
              title: 'طباعة',
              onPressed: () async {
                addBillController.printInvoice(Get.find<AddBillPlutoController>().generateBillRecords);
              },
            ),
            AppButton(title: "E-Invoice", onPressed: () {}, iconData: Icons.link),
          ],
        ],
      ),
    );
  }
}
