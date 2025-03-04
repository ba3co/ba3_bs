import 'package:ba3_bs/core/constants/app_constants.dart';
import 'package:ba3_bs/core/constants/app_strings.dart';
import 'package:ba3_bs/core/helper/extensions/basic/list_extensions.dart';
import 'package:ba3_bs/features/accounts/controllers/account_statement_controller.dart';
import 'package:ba3_bs/features/bond/data/models/entry_bond_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/app_ui_utils.dart';
import '../../../../core/widgets/pluto_grid_with_app_bar_.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({
    super.key,
  });

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
          tableSourceModels: controller.filteredEntryBondItems
              .mergeBy(
                (entry) => entry.originId,
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
          bottomChild: Padding(
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
                      AppUIUtils.formatDecimalNumberWithCommas(controller.debitValue),
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
                      AppUIUtils.formatDecimalNumberWithCommas(controller.creditValue),
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
                      AppUIUtils.formatDecimalNumberWithCommas(controller.totalValue),
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