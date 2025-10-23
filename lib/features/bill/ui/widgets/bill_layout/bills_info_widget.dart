import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/styling/app_colors.dart';
import '../../../../../core/styling/app_text_style.dart';
import '../../../../../core/widgets/organized_widget.dart';
import '../../../controllers/bill/all_bills_controller.dart';
import 'all_bills_types_list.dart';

class BillsInfoWidget extends StatelessWidget {
  const BillsInfoWidget({
    super.key,
    required this.allBillsController,
  });

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    return OrganizedWidget(
      titleWidget: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Text(
              AppStrings.bills.tr,
              style: AppTextStyles.headLineStyle2.copyWith(color: AppColors.blueColor),
            ),
            Spacer(),
            IconButton(
              tooltip: AppStrings.refresh.tr,
              icon: Icon(
                FontAwesomeIcons.refresh,
                color: AppColors.lightBlueColor,
              ),
              onPressed: allBillsController.refreshBillsTypes,
            ),
            PopupMenuButton<String>(
              tooltip: AppStrings.options.tr,
              onSelected: (value) {
                if (value == AppConstants.serialNumbersStatement) {
                  _showSerialNumberDialog(context, allBillsController);
                }
              },
              itemBuilder: (BuildContext context) =>
              <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: AppConstants.serialNumbersStatement,
                  child: Row(
                    children: [
                      Icon(FontAwesomeIcons.file, color: Colors.black54),
                      SizedBox(width: 8),
                      Text(AppStrings.serialNumbersStatement.tr),
                    ],
                  ),
                ),

              ],
              icon: Icon(
                FontAwesomeIcons.ellipsisVertical,
                color: AppColors.lightBlueColor,
              ),
            ),
          ],
        ),
      ),
      bodyWidget: GetBuilder<AllBillsController>(
        builder: (controller) => AllBillsTypesList(allBillsController: controller),
      ),
    );
  }
}
void _showSerialNumberDialog(BuildContext context, AllBillsController allBillsController) {
  String serialNumberInput = '';
  Get.dialog(
    AlertDialog(
      title: Text(AppStrings.enterSerialNumber.tr),
      content: StatefulBuilder(
        builder: (context, setState) {
          return TextField(
            decoration: InputDecoration(
              labelText: AppStrings.serialNumber.tr,
            ),
            onChanged: (value) {
              serialNumberInput = value;
            },
          );
        },
      ),
      actions: <Widget>[
        TextButton(
          child: Text(AppStrings.cancel.tr),
          onPressed: () {
            Get.back();
          },
        ),
        TextButton(
          child: Text(AppStrings.confirm.tr),
          onPressed: () {
            Get.back();
            if (serialNumberInput.isEmpty) return;
            allBillsController.getSerialNumberStatement(serialNumberInput, context: context);
          },
        ),
      ],
    ),
  );
}