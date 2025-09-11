import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/core/widgets/option_drop_down.dart';
import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/bill/ui/widgets/get_bill_types_checklist.dart';
import '../constants/app_strings.dart';
import '../helper/enums/enums.dart';
import '../styling/app_colors.dart';
import '../widgets/app_button.dart';
import '../widgets/option_text_widget.dart';

class AccountFilterDialog extends StatelessWidget {
  const AccountFilterDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: GetBuilder<AccountStatementController>(builder: (controller) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: AppColors.lightBlueColor,
                        ),
                      ),
                      child: Column(
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
                            onSubmitted: controller.onMinAmountSubmitted,
                          ),
                          OptionTextWidget(
                            title: 'المجموع الأعلى',
                            controller: controller.maxAmountController,
                            onSubmitted: controller.onMaxAmountSubmitted,
                          ),
                          OptionDropdownWidget(
                            title: AppStrings.bond.tr,
                            value: controller.selectedType.value,
                            listValue: BondItemType.values.map((e) => e.label).toList(),
                            label: "اختر نوع السند",
                            onChange: controller.onBondItemTypeSubmitted,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            child: BillTypesChecklist(
                              onItemSelected: (type) {

                                type.printDetails();
                                controller.onBillTypeAdded(type.billTypeId??"no id");
                              },
                              onItemDeselected: (type) {
                                controller.onBillTypeRemoved(type.billTypeId??"no id");
                              },
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 15,
                    children: [
                      AppButton(
                        title: AppStrings.confirm.tr,
                        iconData: Icons.check,
                        onPressed: () {
                          controller
                            ..fetchAccountEntryBondItems(true)
                            ..navigateToAccountStatementScreen(context);
                        },
                      ),
                      if (RoleItemType.administrator.hasAdminPermission)
                        AppButton(
                          title: "${AppStrings.confirm.tr}  new way",
                          iconData: Icons.check,
                          onPressed: () {
                            controller
                              ..fetchAccountEntryBondItems(false)
                              ..navigateToAccountStatementScreen(context);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}


// import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
// import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
// import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../constants/app_strings.dart';
// import '../styling/app_colors.dart';
// import '../widgets/app_button.dart';
// import '../widgets/option_text_widget.dart';
//
// class AccountFilterDialog extends StatelessWidget {
//   const AccountFilterDialog({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Directionality(
//         textDirection: TextDirection.rtl,
//         child: GetBuilder<AccountStatementController>(builder: (controller) {
//           return Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(15),
//                       decoration: BoxDecoration(
//                         color: AppColors.whiteColor,
//                         borderRadius: BorderRadius.circular(15),
//                         border: Border.all(
//                           color: AppColors.lightBlueColor,
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: <Widget>[
//                           const Text('خيارت العرض'),
//                           const SizedBox(height: 15),
//                           OptionTextWidget(
//                               title: 'اسم الحساب :  ',
//                               controller: controller.accountNameController,
//                               onSubmitted: (text) {
//                                 controller.onAccountNameSubmitted(text, context);
//                               }),
//                           OptionTextWidget(
//                             title: 'من تاريخ :  ',
//                             controller: controller.startDateController,
//                             onSubmitted: controller.onStartDateSubmitted,
//                           ),
//                           OptionTextWidget(
//                             title: 'الى تاريخ :  ',
//                             controller: controller.endDateController,
//                             onSubmitted: controller.onEndDateSubmitted,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 Spacer(),
//                 Center(
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     spacing: 15,
//                     children: [
//                       AppButton(
//                         title: AppStrings.confirm.tr,
//                         iconData: Icons.check,
//                         onPressed: () {
//                           controller
//                             ..fetchAccountEntryBondItems(true)
//                             ..navigateToAccountStatementScreen(
//                               context,
//                             );
//                         },
//                       ),
//                       if (RoleItemType.administrator.hasAdminPermission)
//                         AppButton(
//                           title: "${AppStrings.confirm.tr}  new way",
//                           iconData: Icons.check,
//                           onPressed: () {
//                             controller
//                               ..fetchAccountEntryBondItems(false)
//                               ..navigateToAccountStatementScreen(
//                                 context,
//                               );
//                           },
//                         ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }