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
    return Material(
      type: MaterialType.transparency,
      child: Directionality(
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
                            Text(AppStrings.viewOptions.tr),
                            const SizedBox(height: 15),
                            OptionTextWidget(
                                title: AppStrings.accountName.tr,
                                controller: controller.accountNameController,
                                onSubmitted: (text) {
                                  controller.onAccountNameSubmitted(text, context);
                                }),
                            OptionTextWidget(
                              title: "${AppStrings.from.tr} - ${AppStrings.date.tr}",
                              controller: controller.startDateController,
                              onSubmitted: controller.onStartDateSubmitted,
                            ),
                            OptionTextWidget(
                              title: "${AppStrings.to.tr} - ${AppStrings.date.tr}",
                              controller: controller.endDateController,
                              onSubmitted: controller.onEndDateSubmitted,
                            ),
                            OptionTextWidget(
                              title: "${AppStrings.min.tr} - ${AppStrings.amount.tr}",
                              controller: controller.minAmountController,
                              onSubmitted: controller.onMinAmountSubmitted,
                            ),
                            OptionTextWidget(
                              title: "${AppStrings.max.tr} - ${AppStrings.amount.tr}",
                              controller: controller.maxAmountController,
                              onSubmitted: controller.onMaxAmountSubmitted,
                            ),
                            OptionDropdownWidget(
                              title: AppStrings.bondType.tr,
                              value: controller.selectedType.value,
                              listValue: BondItemType.values.map((e) => e.label).toList(),
                              label: AppStrings.bondType.tr,
                              onChange: controller.onBondItemTypeSubmitted,
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: SizedBox(
                                child: BillBondChequeTypesChecklist(
                                    initiallySelectedBillTypes: controller.selectedBillTypeIds,
                                    initiallySelectedBondTypes: controller.selectedBondTypeIds,
                                    initiallySelectedChequeTypes: controller.selectedChequeTypeIds,
                                    onBillTypeSelected: (type) {
                                      type.printDetails();
                                      controller.onItemSubmitted(type);
                                    },
                                    onBillTypeDeselected: (type) {
                                      controller.onItemRemoved(type);
                                    },
                                    onBondTypeSelected: (type) {
                                      controller.onItemSubmitted(type);
                                    },
                                    onBondTypeDeselected: (type) {
                                      controller.onItemRemoved(type);
                                    },
                                    onChequeTypeSelected: (type) {
                                      controller.onItemSubmitted(type);
                                    },
                                    onChequeTypeDeselected: (type) {
                                      controller.onItemRemoved(type);
                                    }),
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
