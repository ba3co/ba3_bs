import 'package:ba3_bs/core/helper/extensions/role_item_type_extension.dart';
import 'package:ba3_bs/features/bill/controllers/bill/all_bills_controller.dart';
import 'package:ba3_bs/features/users_management/data/models/role_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../core/helper/enums/enums.dart';
import 'bill_type_item_widget.dart';
import 'bill_type_shimmer_widget.dart';

class AllBillsTypesList extends StatelessWidget {
  const AllBillsTypesList({super.key, required this.allBillsController});

  final AllBillsController allBillsController;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: allBillsController.getBillsTypesRequestState.value == RequestState.loading
              ? List.generate(10, (index) => const BillTypeShimmerWidget()) // Show shimmer placeholders
              :RoleItemType.viewBill.hasAdminPermission? allBillsController.billsTypes
                  .map(
                    (billTypeModel) => BillTypeItemWidget(
                      text: billTypeModel.fullName!,
                      color: Color(billTypeModel.color!),
                      onTap: () {
                        allBillsController.openFloatingBillDetails(context, billTypeModel);
                        // allBillsController.fetchAllBillsByType( billTypeModel);
                      },
                      pendingBillsCounts: allBillsController.pendingBillsCounts(billTypeModel),
                      allBillsCounts: allBillsController.allBillsCounts(billTypeModel),
                      onPendingBillsPressed: () {
                        allBillsController.fetchPendingBills(billTypeModel);
                      },
                    ),
                  )
                  .toList()
              : [
            BillTypeItemWidget(
              text: BillType.sales.billTypeModel.fullName!,
              color: Color(BillType.sales.billTypeModel.color!),
              onTap: () {
                allBillsController.openFloatingBillDetails(context, BillType.sales.billTypeModel);
                // allBillsController.fetchAllBillsByType( billTypeModel);
              },
              pendingBillsCounts: allBillsController.pendingBillsCounts(BillType.sales.billTypeModel),
              allBillsCounts: allBillsController.allBillsCounts(BillType.sales.billTypeModel),
              onPendingBillsPressed: () {
                allBillsController.fetchPendingBills(BillType.sales.billTypeModel);
              },
            )
          ],
        );
      },
    );
  }
}
