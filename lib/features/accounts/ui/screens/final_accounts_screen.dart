import 'dart:developer';

import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/core/helper/extensions/getx_controller_extensions.dart';
import 'package:ba3_bs/core/styling/app_colors.dart';
import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/dialogs/loading_dialog.dart';
import '../../../../core/helper/enums/enums.dart';
import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';
import '../../../bond/data/models/entry_bond_model.dart';

class FinalAccountScreen extends StatelessWidget {
  const FinalAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.finalAccounts.tr),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: FinalAccounts.values.map((account) {
                return Column(
                  children: [
                    _buildAccountCard(account),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        GetBuilder<AccountStatementController>(builder: (controller) {
          log('RequestState.loading ${controller.fetchFinalAccountsStatementRequestState == RequestState.loading}');

          return LoadingDialog(
            isLoading: controller.fetchFinalAccountsStatementRequestState == RequestState.loading,
            message: AppStrings.finalAccounts.tr,
            fontSize: 14.sp,
          );
        }),
      ],
    );
  }

  Widget _buildAccountCard(FinalAccounts account) => Card(
        elevation: 4,
        color: AppColors.lightBlueColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: Icon(_getIconForAccount(account), size: 32, color: Colors.white),
          title: Text(account.accName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.white),
          onTap: () {
            final controller = read<AccountStatementController>();
            controller.navigateToFinalAccountDetails();
            controller.fetchFinalAccountsStatements(account);
          },
        ),
      );

  IconData _getIconForAccount(FinalAccounts account) {
    switch (account) {
      case FinalAccounts.tradingAccount:
        return Icons.shopping_cart;
      case FinalAccounts.profitAndLoss:
        return Icons.trending_up;
      case FinalAccounts.balanceSheet:
        return Icons.account_balance;
    }
  }
}

class FinalAccountDetailsScreen extends StatelessWidget {
  const FinalAccountDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AccountStatementController>(
      builder: (controller) {
        return PlutoGridWithAppBar(
          title: controller.screenTitle.tr,
          onLoaded: (e) {},
          onSelected: (event) {
            String originId = event.row?.cells[AppConstants.entryBonIdFiled]?.value;
            controller.launchBondEntryBondScreen(context: context, originId: originId);
          },
          isLoading: controller.isLoading,
          tableSourceModels: controller.finalAccountsEntryBondItems
              .mergeBy(
                (entry) => entry.account.id,
                (accumulated, current) => EntryBondItemModel(
                  account: current.account,
                  amount: accumulated.amount! + current.amount!,
                  bondItemType: current.bondItemType,
                  date: current.date,
                  note: '${current.note} + ${accumulated.note}',
                  originId: current.originId,
                  docId: current.docId,
                ),
              )
              .toList(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.debtor.tr,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppUIUtils.formatDecimalNumberWithCommas(controller.debitFinalAccountValue),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.creditor.tr,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppUIUtils.formatDecimalNumberWithCommas(controller.creditFinalAccountValue),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.theTotal.tr,
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300, fontSize: 24),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      AppUIUtils.formatDecimalNumberWithCommas(controller.totalFinalAccountValue),
                      style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600, fontSize: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
