import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../features/bill/ui/widgets/get_bill_types_checklist.dart';
import '../../features/bond/controllers/bonds/bond_type_controller.dart';
import '../../features/bond/data/models/bond_type.dart';
import '../../features/cheques/controllers/cheques/cheque_type_conntroller.dart';
import '../../features/cheques/data/models/cheque_type.dart';
import '../../features/patterns/controllers/pattern_controller.dart';
import '../../features/patterns/data/models/bill_type_model.dart';
import '../constants/app_strings.dart';
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
                            Text(AppStrings.viewOptions.tr, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
                            // OptionDropdownWidget(
                            //   title: AppStrings.bondType.tr,
                            //   value: controller.selectedType.value,
                            //   listValue: BondItemType.values.map((e) => e.label).toList(),
                            //   label: AppStrings.bondType.tr,
                            //   onChange: controller.onBondItemTypeSubmitted,
                            // ),
                            const SizedBox(height: 20),
                            Text(AppStrings.filter.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child:Column(
                                children: [
                                  FutureBuilder<List<BillTypeModel>>(
                                    future: Get.find<PatternController>().getAllBillTypes(false),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      final billTypes = snapshot.data!;
                                      final controller = Get.find<AccountStatementController>();

                                      return Obx(() => SelectableChecklistSection<BillTypeModel>(
                                        title: AppStrings.bills.tr,
                                        items: billTypes,
                                        initiallySelected: controller.selectedBillTypeIds,
                                        displayText: (e) => e.fullName!,
                                        isAllSelected: controller.isBillTypesSelectedAll.value,
                                        onSelectAll: () => controller.selectAllBills(billTypes),
                                        onUnselectAll: controller.unselectAllBills,
                                        onItemSelected: controller.onItemSubmitted,
                                        onItemDeselected: controller.onItemRemoved,
                                      ));
                                    },
                                  ),

                                  FutureBuilder<List<BondTypeModel>>(
                                    future: Get.find<BondTypeController>().getAllBondTypes(true),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      final bondTypes = snapshot.data!;
                                      final controller = Get.find<AccountStatementController>();

                                      return Obx(() => SelectableChecklistSection<BondTypeModel>(
                                        title: AppStrings.bonds.tr,
                                        items: bondTypes,
                                        initiallySelected: controller.selectedBondTypeIds,
                                        displayText: (e) => e.value,
                                        isAllSelected: controller.isBondTypesSelectedAll.value,
                                        onSelectAll: () => controller.selectAllBonds(bondTypes),
                                        onUnselectAll: controller.unselectAllBonds,
                                        onItemSelected: controller.onItemSubmitted,
                                        onItemDeselected: controller.onItemRemoved,
                                      ));
                                    },
                                  ),
                                  FutureBuilder<List<ChequeType>>(
                                    future: Get.find<ChequeTypeController>().getAllCheques(true),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return const CircularProgressIndicator();
                                      }

                                      final chequeTypes =
                                      snapshot.data!.where((e) => e.label.isNotEmpty).toList();
                                      final controller = Get.find<AccountStatementController>();

                                      return Obx(() => SelectableChecklistSection<ChequeType>(
                                        title: AppStrings.cheques.tr,
                                        items: chequeTypes,
                                        initiallySelected: controller.selectedChequeTypeIds,
                                        displayText: (e) => e.value,
                                        isAllSelected: controller.isChequeTypesSelectedAll.value,
                                        onSelectAll: () => controller.selectAllCheques(chequeTypes),
                                        onUnselectAll: controller.unselectAllCheques,
                                        onItemSelected: controller.onItemSubmitted,
                                        onItemDeselected: controller.onItemRemoved,
                                      ));
                                    },
                                  ),
                                ],
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
