import 'package:ba3_bs/core/widgets/option_drop_down.dart';
import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/bill/ui/widgets/get_bill_types_checklist.dart';
import '../constants/app_strings.dart';
import '../helper/enums/enums.dart';
import '../styling/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/option_text_widget.dart';

Dialog showAccountFilterDialog(BuildContext context) {
  return Dialog(
    backgroundColor: AppColors.backGroundColor,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<AccountStatementController>(builder: (controller) {
          return SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const Text('خيارت العرض'),
                const SizedBox(height: 15),
                OptionTextWidget(
                    title: 'اسم الحساب :  ',
                    controller: controller.accountNameController,
                    onSubmitted: (text) {
                      controller.onAccountNameSubmitted(text, context);
                    }),
                OptionTextWidget(
                  title: 'من تاريخ :  ',
                  controller: controller.startDateController,
                  onSubmitted: controller.onStartDateSubmitted,
                ),
                OptionTextWidget(
                  title: 'الى تاريخ :  ',
                  controller: controller.endDateController,
                  onSubmitted: controller.onEndDateSubmitted,
                ),
                OptionTextWidget(
                  title: 'المجموع الأدنى',
                  controller: controller.minAmountController,
                  onSubmitted: controller.onMinAmountSubmitted ,
                ),
                OptionTextWidget(
                  title: 'المجموع الأعلى',
                  controller: controller.maxAmountController,
                  onSubmitted: controller.onMaxAmountSubmitted,
                ),
                OptionDropdownWidget(title:AppStrings.bond.tr , value: controller.selectedType.value, listValue:  BondItemType.values.map((e) => e.label).toList(), label:"اختر نوع السند", onChange: controller.onBondItemTypeSubmitted),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: Get.width/2.5,
                  child: BillTypesChecklist(
                    onItemSelected: (type) {
                      controller.onBillTypeAdded(type);
                    },
                    onItemDeselected: (type) {
                      controller.onBillTypeRemoved(type); // remove it
                    },
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                AppButton(
                  title: 'موافق',
                  iconData: Icons.check,
                  onPressed: () {
                    controller
                      ..fetchAccountEntryBondItems()
                      ..navigateToAccountStatementScreen();
                  },
                ),
              ],
            ),
          );
        }),
      ),
    ),
  );
}